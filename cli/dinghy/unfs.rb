require 'forwardable'
require 'timeout'
require 'socket'

require 'dinghy/unfs_root_daemon'

class Unfs
  extend Forwardable
  attr_reader :machine, :port

  def_delegators :daemon, :name, :status, :running?, :logfile

  def initialize(machine)
    @machine = machine
    @port = 19091
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
  def up(custom_export_options)
    write_exports!(custom_export_options)
    puts starting_message
    system("sudo", "#{Dinghy.dir}/bin/dinghy", "nfs", "start", Dinghy.var.to_s, *command)
  end

  def halt
    puts stopping_message
    system("sudo", "#{Dinghy.dir}/bin/dinghy", "nfs", "stop", Dinghy.var.to_s)
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
    ENV['DINGHY_HOST_MOUNT_DIR'] || Dinghy.home
  end

  def guest_mount_dir
    ENV['DINGHY_GUEST_MOUNT_DIR'] || Dinghy.home
  end

  protected

  def daemon
    UnfsRootDaemon.new(Dinghy.var, [])
  end

  def write_exports!(custom_export_options)
    File.open(exports_filename, 'wb') { |f| f.write exports_body(custom_export_options) }
  end

  def exports_body(custom_export_options)
    export_options = if custom_export_options.nil?
      "rw,all_squash,anonuid=#{Process.uid},anongid=#{Process.gid}"
    else
      custom_export_options
    end

    <<-BODY.gsub(/^    /, '')
    "#{host_mount_dir}" #{machine.vm_ip}(#{export_options})
    BODY
  end

  def exports_filename
    Dinghy.home_dinghy+"machine-nfs-exports-#{machine.name}"
  end

  def starting_message
    "Starting #{name} daemon, this will require sudo"
  end

  def stopping_message
    "Stopping #{name} daemon, this will require sudo"
  end

  def command
    [
      "#{Dinghy.brew}/sbin/unfsd",
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
    rescue Errno::ECONNREFUSED, Timeout::Error
      false
    end
  end
end
