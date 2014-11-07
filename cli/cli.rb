$LOAD_PATH << File.dirname(__FILE__)+"/thor-0.19.1/lib"
require 'thor'

MEM_DEFAULT=2048
CPU_DEFAULT=1

class DinghyCLI < Thor
  option :memory,
    type: :numeric,
    aliases: :m,
    desc: "virtual machine memory size (in MB) (default #{MEM_DEFAULT})"
  option :cpus,
    type: :numeric,
    aliases: :c,
    desc: "number of CPUs to allocate to the virtual machine (default #{CPU_DEFAULT})"
  option :provider,
    aliases: :p,
    desc: "which Vagrant provider to use, only takes affect when initializing a new VM"
  desc "up", "start the Docker VM and NFS service"
  def up
    vagrant = Vagrant.new
    unfs = Unfs.new
    vagrant.up(options.dup)
    unfs.up
    vagrant.mount(unfs)
    vagrant.install_docker_keys
    CheckEnv.new.run
  end

  desc "ssh [args...]", "run vagrant ssh on the VM"
  def ssh(*args)
    Vagrant.new.ssh(args.join(' '))
  end

  desc "status", "get VM and NFS status"
  def status
    puts " VM: #{Vagrant.new.status}"
    puts "NFS: #{Unfs.new.status}"
  end

  desc "halt", "stop the VM and NFS"
  def halt
    Vagrant.new.halt
    Unfs.new.halt
  end

  option :force,
    type: :boolean,
    aliases: :f,
    desc: "destroy without confirmation"
  desc "destroy", "stop and delete all traces of the VM"
  def destroy
    halt
    Vagrant.new.destroy(force: options[:force])
  end
end

require 'pathname'
require 'fileutils'
require 'timeout'
require 'socket'

BREW = Pathname.new(`brew --prefix`.strip)
DINGHY = BREW+"opt/dinghy/etc"
VAGRANT = BREW+"var/dinghy/vagrant"
HOST_IP = "192.168.42.1"
VM_IP = "192.168.42.10"

class Unfs
  def up
    halt

    FileUtils.ln_s(plist_path, plist_install_path)
    unless system("launchctl", "load", plist_install_path)
      raise("Could not start the NFS daemon.")
    end

    wait_for_unfs
  end

  def wait_for_unfs
    Timeout.timeout(20) do
      puts "Waiting for NFS daemon..."
      while status != :running
        sleep 1
      end
    end
  end

  def status
    begin
      TCPSocket.open("192.168.42.1", 19321)
      :running
    rescue Errno::ECONNREFUSED
      :stopped
    end
  end

  def halt
    if File.exist?(plist_install_path)
      puts "Stopping NFS daemon..."
      system("launchctl", "unload", plist_install_path)
      FileUtils.rm(plist_install_path)
    end
  end

  def mount_dir
    ENV.fetch("HOME")
  end

  def plist_install_path
    "#{ENV.fetch("HOME")}/Library/LaunchAgents/dinghy.unfs.plist"
  end

  def plist_path
    DINGHY+"dinghy.unfs.plist"
  end
end

class Vagrant
  def up(options = {})
    check_for_vagrant
    cd

    ENV["DINGHY_PRIVATE_IP"] = VM_IP
    if !created?
      # only send the default when first creating the VM,
      # so that if they don't specify these parameters on halt/up
      # we'll keep using the current values.
      options[:memory] ||= MEM_DEFAULT
      options[:cpus] ||= CPU_DEFAULT
    end
    ENV["DINGHY_VM_RAM"] = options[:memory].to_s if options[:memory]
    ENV["DINGHY_VM_CPUS"] = options[:cpus].to_s  if options[:cpus]

    system "vagrant up #{options[:provider] && "--provider #{options[:provider]}"}"
    if command_failed?
      raise("There was an error bringing up the Vagrant box. Dinghy cannot continue.")
    end
  end

  def check_for_vagrant
    `vagrant --version`
    if command_failed?
      puts <<-EOS
Vagrant is not installed. Please install Vagrant before continuing.
https://www.vagrantup.com
      EOS
    end
  end

  def ssh(command)
    cd
    if command && !command.empty?
      system "vagrant", "ssh", "--", command
      if command_failed?
        raise("Error executing command: #{command}")
      end
    else
      system "vagrant", "ssh"
    end
  end

  def status
    cd
    output = `vagrant status --machine-readable`.split("\n")
    output.find { |line| line =~ /state-human-short/ }.split(",")[3]
  end

  def mount(unfs)
    puts "Mounting NFS #{unfs.mount_dir}"
    ssh("sudo mount -t nfs #{HOST_IP}:#{unfs.mount_dir} #{unfs.mount_dir} -o nfsvers=3,tcp,mountport=19321,port=19321,nolock,hard,intr")
  end

  def halt
    cd
    system "vagrant halt"
  end

  def destroy(options = {})
    cd
    system "vagrant destroy #{options[:force] && '--force'}"
  end

  def install_docker_keys
    cd
    FileUtils.mkdir_p(key_dir)
    %w[key.pem ca.pem cert.pem].each do |cert|
      target = key_dir+cert
      puts "Writing #{target}"
      contents = `vagrant ssh -- cat .docker/#{cert}`
      if command_failed?
        raise("Error contacting the vagrant instance.")
      end
      File.open(target, "wb") { |f| f.write contents }
    end
  end

  def command_failed?
    !$?.success?
  end

  def cd
    Dir.chdir(VAGRANT)
  end

  def key_dir
    Pathname.new("#{ENV.fetch("HOME")}/.dinghy/certs")
  end

  def created?
    `vagrant status --machine-readable` !~ /not_created/
  end
end

class CheckEnv
  def run
    if expected.all? { |name,value| ENV[name] == value }
      puts "Your environment variables are already set correctly."
    else
      puts "To connect the Docker client to the Docker daemon, please set:"
      expected.each { |name,value| puts "    export #{name}=#{value}" }
    end
  end

  def expected
    {
      "DOCKER_HOST" => "tcp://127.0.0.1:2376",
      "DOCKER_CERT_PATH" => "#{ENV.fetch("HOME")}/.dinghy/certs",
      "DOCKER_TLS_VERIFY" => "1",
    }
  end
end
