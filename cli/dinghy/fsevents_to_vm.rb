require 'dinghy/plist'

class FseventsToVm
  include Plist
  BIN_PATH = "/usr/bin/fsevents_to_vm"
  VERSION = "~> 1.0"

  def up
    install_if_necessary!
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
    return if $?.success?
    puts "Installing fsevents_to_vm, this will require sudo"
    system!("installing", "sudo", "/System/Library/Frameworks/Ruby.framework/Versions/Current/usr/bin/gem", "install", "--no-rdoc", "--no-ri", "fsevents_to_vm", "-v", VERSION)
  end
end
