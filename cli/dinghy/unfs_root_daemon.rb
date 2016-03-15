require 'dinghy/daemon'

class UnfsRootDaemon
  include Dinghy::Daemon
  attr_reader :dir, :command

  def initialize(var_dir, command_args)
    @dir = var_dir
    @command = command_args
  end

  def name
    "NFS"
  end
end
