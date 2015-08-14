require 'timeout'
require 'socket'

require 'dinghy/plist'

class Unfs
  include RootPlist

  attr_reader :machine

  def initialize(machine)
    @machine = machine
  end

  def up
    super
    wait_for_unfs
  end

  def wait_for_unfs
    Timeout.timeout(20) do
      puts "Waiting for #{name} daemon..."
      while status != "running"
        sleep 1
      end
    end
  end

  def status
    begin
      Timeout.timeout(1) do
        TCPSocket.open(machine.host_ip, 19321)
      end
      "running"
    rescue Errno::ECONNREFUSED, Timeout::Error
      "not running"
    end
  end

  def host_mount_dir
    ENV['DINGHY_HOST_MOUNT_DIR'] || HOME
  end

  def guest_mount_dir
    ENV['DINGHY_GUEST_MOUNT_DIR'] || HOME
  end

  def plist_name
    "dinghy.unfs.plist"
  end

  def name
    "NFS"
  end
end
