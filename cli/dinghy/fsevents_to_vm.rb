require 'dinghy/daemon'

class FseventsToVmRunner
  include Dinghy::Daemon

  attr_reader :machine

  def initialize(machine)
    @machine = machine
  end

  def up
    increase_inotify_limit
    super
  end

  def name
    "FsEvents"
  end

  protected

  def increase_inotify_limit
    machine.ssh("echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf > /dev/null")
    machine.ssh("sudo sysctl -p > /dev/null")
  end

  def run
    $LOAD_PATH << File.expand_path(File.dirname(__FILE__)+"/../net-ssh/lib")
    $LOAD_PATH << File.expand_path(File.dirname(__FILE__)+"/../rb-fsevent/lib")
    $LOAD_PATH << File.expand_path(File.dirname(__FILE__)+"/../fsevents_to_vm/lib")
    require 'fsevents_to_vm/cli'
    args = [
      'start',
      "--ssh-identity-file=#{machine.ssh_identity_file_path}",
      "--ssh-ip=#{machine.vm_ip}"
    ]
    $0 = 'fsevents_to_vm'
    FseventsToVm::Cli.start(args)
  end
end
