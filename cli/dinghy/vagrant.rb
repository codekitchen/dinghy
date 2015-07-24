require 'dinghy/constants'

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

  def running?
    status == "running"
  end

  def mount(unfs)
    puts "Mounting NFS #{unfs.guest_mount_dir}"
    ssh("sudo mount -t nfs #{HOST_IP}:#{unfs.host_mount_dir} #{unfs.guest_mount_dir} -o nfsvers=3,udp,mountport=19321,port=19321,nolock,hard,intr")
  end

  def halt
    cd
    system "vagrant halt"
  end

  def destroy(options = {})
    cd
    system "vagrant destroy #{options[:force] && '--force'}"
  end

  def upgrade
    cd
    system "vagrant box update"
    # ideally we wouldn't destroy the box if they're already running the newest
    # version
    destroy(force: true)
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
    Pathname.new("#{HOME}/.dinghy/certs")
  end

  def created?
    `vagrant status --machine-readable` !~ /not_created/
  end
end
