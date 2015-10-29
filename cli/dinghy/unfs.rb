require 'timeout'
require 'socket'

require 'dinghy/daemon'

class Unfs
  include Dinghy::Daemon

  attr_reader :machine

  def initialize(machine)
    @machine = machine
  end

  def up
    if root?
      super
    else
      write_exports!
      system("sudo", "#{DINGHY}/bin/dinghy", "nfs", "start")
      wait_for_unfs
    end
  end

  def halt
    if root?
      super
    else
      system("sudo", "#{DINGHY}/bin/dinghy", "nfs", "stop")
    end
  end

  def root?
    Process.uid == 0
  end

  def wait_for_unfs
    Timeout.timeout(20) do
      puts "Waiting for #{name} daemon..."
      while status != "running"
        sleep 1
      end
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

  protected

  def write_exports!
    File.open(exports_filename, 'wb') { |f| f.write exports_body }
  end

  def exports_body
    <<-BODY.gsub(/^    /, '')
    "#{HOME}" #{machine.vm_ip}(rw,all_squash,anonuid=#{Process.uid},anongid=#{Process.gid})
    BODY
  end

  def exports_filename
    HOME_DINGHY+"machine-nfs-exports-#{machine.name}"
  end

  def starting_message
    "Starting #{name} daemon, this will require sudo"
  end

  def stopping_message
    "Stopping #{name} daemon, this will require sudo"
  end

  def command
    [
      "#{BREW}/sbin/unfsd",
      "-e", "#{exports_filename}",
      "-n", "19321",
      "-m", "19321",
      "-l", "#{machine.host_ip}",
      "-p",
      "-b",
      "-d"
    ]
  end
end
