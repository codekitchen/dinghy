$LOAD_PATH << File.dirname(__FILE__)+"/thor/lib"
require 'thor'

$LOAD_PATH << File.dirname(__FILE__)

require 'dinghy/check_env'
require 'dinghy/dnsmasq'
require 'dinghy/http_proxy'
require 'dinghy/preferences'
require 'dinghy/unfs'
require 'dinghy/vagrant'
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
    desc: "which Vagrant provider to use, only takes effect when initializing a new VM"
  option :proxy,
    type: :boolean,
    desc: "start the HTTP proxy as well"
  desc "up", "start the Docker VM and services"
  def up
    vagrant = Vagrant.new
    unfs = Unfs.new
    vagrant.up(options.dup)
    unfs.up
    vagrant.mount(unfs)
    vagrant.install_docker_keys
    Dnsmasq.new.up
    proxy = options[:proxy] || (options[:proxy].nil? && !proxy_disabled?)
    if proxy
      HttpProxy.new.up
    end
    CheckEnv.new.run

    preferences.update(proxy: proxy)
  end

  desc "ssh [args...]", "run vagrant ssh on the VM"
  def ssh(*args)
    Vagrant.new.ssh(args.join(' '))
  end

  desc "status", "get VM and services status"
  def status
    puts "  VM: #{Vagrant.new.status}"
    puts " NFS: #{Unfs.new.status}"
    puts " DNS: #{Dnsmasq.new.status}"
    puts "HTTP: #{HttpProxy.new.status}"
  end

  desc "ip", "get the VM's IP address"
  def ip
    if Vagrant.new.running?
      puts VM_IP
    else
      $stderr.puts "The VM is not running, `dinghy up` to start"
      exit 1
    end
  end

  desc "halt", "stop the VM and services"
  def halt
    Vagrant.new.halt
    Unfs.new.halt
    Dnsmasq.new.halt
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
    Vagrant.new.destroy(force: options[:force])
  end

  desc "upgrade", "upgrade the boot2docker VM to the newest available"
  def upgrade
    halt
    Vagrant.new.upgrade
    puts "VM base box updated, run `dinghy up` to re-create the VM"
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
    preferences[:proxy] == false
  end
end
