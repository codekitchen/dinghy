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
    write_exports!
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
    rescue Errno::ECONNREFUSED, Timeout::Error, JSON::ParserError
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

  def plist_body
    <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>KeepAlive</key>
  <true/>
  <key>Label</key>
  <string>dinghy.unfs</string>
  <key>ProgramArguments</key>
  <array>
    <string>#{BREW}/sbin/unfsd</string>
    <string>-e</string>
    <string>#{exports_filename}</string>
    <string>-n</string>
    <string>19321</string>
    <string>-m</string>
    <string>19321</string>
    <string>-l</string>
    <string>#{machine.host_ip}</string>
    <string>-p</string>
    <string>-b</string>
    <string>-d</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>WorkingDirectory</key>
  <string>#{BREW}</string>
</dict>
</plist>
    XML
  end
end
