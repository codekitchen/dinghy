require 'timeout'
require 'socket'

require 'dinghy/plist'

class Unfs
  include RootPlist

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
        TCPSocket.open(HOST_IP, 19321)
      end
      "running"
    rescue Errno::ECONNREFUSED, Timeout::Error
      "not running"
    end
  end

  def mount_dir
    HOME
  end

  def plist_name
    "dinghy.unfs.plist"
  end

  def name
    "NFS"
  end
end
