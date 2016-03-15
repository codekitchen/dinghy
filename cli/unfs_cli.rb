$LOAD_PATH << File.dirname(__FILE__)+"/daemons/lib"
$LOAD_PATH << File.dirname(__FILE__)
require 'dinghy/unfs_root_daemon'

module UnfsCli
  def self.start(op, var_dir, *command)
    if Process.uid != 0
      $stderr.puts "nfs command must be run as root"
      return
    end

    daemon = UnfsRootDaemon.new(var_dir, command)

    case op
    when "start"
      daemon.up
    when "stop"
      daemon.halt
    else
      $stderr.puts "unknown nfs subcommand: #{op}"
    end
  end
end
