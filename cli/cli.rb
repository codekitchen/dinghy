$LOAD_PATH << File.dirname(__FILE__)+"/thor/lib"
require 'thor'

$LOAD_PATH << File.dirname(__FILE__)

require 'dinghy/check_env'
require 'dinghy/dnsmasq'
require 'dinghy/fsevents_to_vm'
require 'dinghy/http_proxy'
require 'dinghy/preferences'
require 'dinghy/unfs'
require 'dinghy/machine'
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
  option :provider,
    aliases: :p,
    desc: "which docker-machine provider to use, only takes effect when initializing a new VM"
  option :proxy,
    type: :boolean,
    desc: "start the HTTP proxy as well"
  option :fsevents,
    type: :boolean,
    desc: "start the FS event forwarder"
  desc "up", "start the Docker VM and services"
  def up
    machine = Machine.new
    unfs = Unfs.new(machine)
    machine.up(options.dup)
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
    CheckEnv.new.run

    preferences.update(
      proxy_disabled: !proxy,
      fsevents_disabled: !fsevents,
    )
  end

  desc "ssh [args...]", "ssh to the VM"
  def ssh(*args)
    Machine.new.ssh(args.join(' '))
  end

  desc "ssh-config", "print ssh configuration for the VM"
  def ssh_config
    puts Machine.new.ssh_config
  end

  desc "status", "get VM and services status"
  def status
    machine = Machine.new
    puts "  VM: #{machine.status}"
    puts " NFS: #{Unfs.new(machine).status}"
    puts "FSEV: #{FseventsToVm.new.status}"
    puts " DNS: #{Dnsmasq.new(machine).status}"
    puts "HTTP: #{HttpProxy.new(machine).status}"
  end

  desc "ip", "get the VM's IP address"
  def ip
    machine = Machine.new
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
    machine = Machine.new
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
    Machine.new.destroy(force: options[:force])
  end

  desc "upgrade", "upgrade the boot2docker VM to the newest available"
  def upgrade
    Machine.new.upgrade
    # TODO: this restarts the box, shutting down the http proxy
  end

  desc "shellinit", "returns env variables to set, should be run like $(dinghy shellinit)"
  def shellinit
    CheckEnv.new.print
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
end
