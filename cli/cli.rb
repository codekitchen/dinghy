$LOAD_PATH << File.dirname(__FILE__)+"/thor/lib"
require 'thor'

$LOAD_PATH << File.dirname(__FILE__)

require 'dinghy/check_env'
require 'dinghy/docker'
require 'dinghy/dnsmasq'
require 'dinghy/fsevents_to_vm'
require 'dinghy/http_proxy'
require 'dinghy/preferences'
require 'dinghy/unfs'
require 'dinghy/machine'
require 'dinghy/machine/create_options'
require 'dinghy/ssh'
require 'dinghy/system'
require 'dinghy/version'

class DinghyCLI < Thor
  option :memory,
    type: :numeric,
    aliases: :m,
    desc: "virtual machine memory size (in MB) (default #{MEM_DEFAULT})"
  option :cpus,
    type: :numeric,
    aliases: :c,
    desc: "number of CPUs to allocate to the virtual machine (default #{CPU_DEFAULT})"
  option :disk,
    type: :numeric,
    aliases: :d,
    desc: "size of the virtual disk to create, in MB (default #{DISK_DEFAULT})"
  option :provider,
    aliases: :p,
    desc: "which docker-machine provider to use, 'virtualbox' or 'vmware'"
  desc "create", "create the docker-machine VM"
  def create
    version_check!

    if machine.created?
      $stderr.puts "The VM '#{machine.name}' already exists in docker-machine."
      $stderr.puts "Run `dinghy up` to bring up the VM, or `dinghy destroy` to delete it."
      exit(1)
    end

    create_options = (preferences[:create] || {}).merge(options)
    create_options['provider'] = machine.translate_provider(create_options['provider'])
    preferences.update(create: create_options)

    if create_options['provider'].nil?
      $stderr.puts("Invalid value for required option --provider. Valid values are: 'virtualbox', 'vmware'")
      exit(1)
    end

    puts "Creating the #{machine.name} VM..."
    machine.create(create_options)
    start_services
  end

  option :proxy,
    type: :boolean,
    desc: "start the HTTP proxy as well"
  option :fsevents,
    type: :boolean,
    desc: "start the FS event forwarder"
  desc "up", "start the Docker VM and services"
  def up
    version_check!

    if machine.running?
      puts "#{machine.name} already running, restarting..."
      halt
    end

    if !machine.created?
      $stderr.puts "The VM '#{machine.name}' does not exist in docker-machine."
      $stderr.puts "Run `dinghy create` to create the VM, `dinghy help create` to see available options."
      exit(1)
    end

    puts "Starting the #{machine.name} VM..."
    start_services
  end

  desc "ssh [args...]", "ssh to the VM"
  def ssh(*args)
    ssh = Ssh.new(machine)
    if args.empty?
      ssh.exec
    else
      ssh.run(*args)
    end
  rescue Ssh::CommandFailed => e
    exit(e.exitstatus)
  end

  desc "ssh-config", "print ssh configuration for the VM"
  def ssh_config
    puts Ssh.new(machine).ssh_config
  end

  desc "status", "get VM and services status"
  def status
    puts "  VM: #{machine.status}"
    puts " NFS: #{Unfs.new(machine).status}"
    puts "FSEV: #{FseventsToVm.new.status}"
    puts " DNS: #{Dnsmasq.new(machine).status}"
    puts "HTTP: #{HttpProxy.new(machine).status}"
  end

  desc "ip", "get the VM's IP address"
  def ip
    if machine.running?
      puts machine.vm_ip
    else
      $stderr.puts "The VM is not running, `dinghy up` to start"
      exit 1
    end
  end

  desc "halt", "stop the VM and services"
  def halt
    FseventsToVm.new.halt
    machine.halt
    Unfs.new(machine).halt
    Dnsmasq.new(machine).halt
  end

  desc "restart", "restart the VM and services"
  def restart
    halt
    up
  end

  option :force,
    type: :boolean,
    aliases: :f,
    desc: "destroy without confirmation"
  desc "destroy", "stop and delete all traces of the VM"
  def destroy
    halt
    machine.destroy(force: options[:force])
  end

  desc "upgrade", "upgrade the boot2docker VM to the newest available"
  def upgrade
    machine.upgrade
    # restart to re-enable the http proxy, etc
    restart
  end

  desc "shellinit", "returns env variables to set, should be run like $(dinghy shellinit)"
  def shellinit
    CheckEnv.new(machine).print
  end

  map "-v" => :version
  desc "version", "display dinghy version"
  def version
    puts "Dinghy #{DINGHY_VERSION}"
  end

  private

  def preferences
    @preferences ||= Preferences.load
  end

  def proxy_disabled?
    preferences[:proxy_disabled] == true
  end

  def fsevents_disabled?
    preferences[:fsevents_disabled] == true
  end

  def machine
    @machine ||= Machine.new
  end

  def start_services
    unfs = Unfs.new(machine)
    machine.up
    unfs.up
    machine.mount(unfs)
    fsevents = options[:fsevents] || (options[:fsevents].nil? && !fsevents_disabled?)
    if fsevents
      FseventsToVm.new.up
    end
    Dnsmasq.new(machine).up
    proxy = options[:proxy] || (options[:proxy].nil? && !proxy_disabled?)
    if proxy
      HttpProxy.new(machine).up
    end
    CheckEnv.new(machine).run

    preferences.update(
      proxy_disabled: !proxy,
      fsevents_disabled: !fsevents,
    )
  end

  REQUIRED_VERSIONS = {
    'docker' => Gem::Version.new("1.8.1"),
    'docker-machine' => Gem::Version.new("0.4.0"),
  }

  def version_check!
    REQUIRED_VERSIONS.each do |command, required_version|
      installed_version = version(command)
      if installed_version < required_version
        $stderr.puts "#{command} version #{installed_version} is too old, please upgrade to version #{required_version}"
        exit(2)
      end
    end
  end

  def version(command)
    text, _ = System.capture_output { system(command, "--version") }
    if System.command_failed?
      raise("Could not check #{command} --version, is it installed?")
    end
    version = text.match(%r{\b\d+\.\d+\.\d+})[0]
    if version.empty?
      raise("Could not check #{command} --version, is it installed?")
    end
    Gem::Version.new(version)
  end
end
