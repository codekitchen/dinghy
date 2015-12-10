require 'timeout'
require 'socket'

require 'dinghy/daemon'

class Unfs
  include Dinghy::Daemon

  attr_reader :machine
  attr_accessor :port

  def initialize(machine)
    @machine = machine
    @port = rand(1000) + 19000
  end

  # We have to jump through some hoops to make this work. unfsd needs to run as
  # root, even though we're squashing all permissions to the user's uid -- as
  # far as I can tell, it's just buggy when run as non-root.
  #
  # But, we don't want to run dinghy as a whole as root, and we want to avoid
  # setuid.
  #
  # So, we sudo out to the dinghy binary again, and run a special command to
  # start unfsd in that sudo'd process.
  def up
    if root?
      super
    else
      write_exports!
      puts starting_message
      system("sudo", "#{DINGHY}/bin/dinghy", "nfs", "start", port.to_s)
    end
  end

  def halt
    if root?
      super
    else
      system("sudo", "#{DINGHY}/bin/dinghy", "nfs", "stop", "0") # port unused
    end
  end

  def wait_for_unfs
    Timeout.timeout(10) do
      puts "Waiting for #{name} daemon..."
      while !daemon_listening?
        sleep 1
      end
    end
    true
  rescue Timeout::Error
    false
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
      "-n", port.to_s,
      "-m", port.to_s,
      "-l", "#{machine.host_ip}",
      "-p",
      "-d"
    ]
  end

  def daemon_listening?
    begin
      Timeout.timeout(1) do
        TCPSocket.open(machine.host_ip, port)
      end
      true
    rescue Errno::ECONNREFUSED, Timeout::Error, JSON::ParserError
      false
    end
  end
end
