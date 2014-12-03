$LOAD_PATH << File.dirname(__FILE__)+"/thor-0.19.1/lib"
require 'thor'

$LOAD_PATH << File.dirname(__FILE__)

require 'dinghy/check_env'
require 'dinghy/dnsmasq'
require 'dinghy/http_proxy'
require 'dinghy/unfs'
require 'dinghy/vagrant'

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
    default: false,
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
    CheckEnv.new.run
    if options[:proxy]
      HttpProxy.new.up
    end
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
end
