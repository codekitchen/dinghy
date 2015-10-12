require 'dinghy/plist'

class FseventsToVm
  include Plist
  BIN_PATH = "#{Gem.bindir}/fsevents_to_vm"
  VERSION = "~> 1.0.1"

  attr_reader :machine

  def initialize(machine)
    @machine = machine
  end

  def up
    install_if_necessary!
    increase_inotify_limit
    super
  end

  def plist_name
    "dinghy.fsevents_to_vm.plist"
  end

  def name
    "FsEvents"
  end

  def status
    if `pgrep fsevents_to_vm`.strip.to_i > 0
      "running"
    else
      "not running"
    end
  end

  protected

  def install_if_necessary!
    %x{/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/gem list -i -v '#{VERSION}' fsevents_to_vm}
    return if $?.success? and File.exists? BIN_PATH
    puts "Installing fsevents_to_vm, this will require sudo"
    system!("installing", "sudo", "/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/gem", "install", "--no-rdoc", "--no-ri", "fsevents_to_vm", "-v", VERSION)
  end

  def increase_inotify_limit
    machine.ssh("echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf > /dev/null")
    machine.ssh("sudo sysctl -p > /dev/null")
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
  <string>dinghy.fsevents_to_vm</string>
  <key>ProgramArguments</key>
  <array>
    <string>#{BIN_PATH}</string>
    <string>start</string>
    <string>--ssh-config-file=#{HOME}/.dinghy/ssh-config</string>
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
