require 'dinghy/constants'
require 'daemons'

module Dinghy::Daemon
  def up
    puts starting_message unless root?
    # remove any old logfile sitting around
    FileUtils.rm(daemon.output_logfile) if File.file?(daemon.output_logfile)
    start
  end

  def daemon
    @daemon ||= begin
      options = { proc: method(:run), mode: :proc, log_output: true, shush: true }
      daemon_group.new_application(options)
    end
  end

  def daemon_group
    @group ||= Daemons::ApplicationGroup.new("dinghy-#{name}", {
      dir_mode: :normal,
      dir: VAR.to_s,
    })
  end

  def halt
    puts stopping_message
    stop
  rescue Errno::ENOENT
    # daemon wasn't running
  end

  def starting_message
    "Starting the #{name} daemon"
  end

  def stopping_message
    "Stopping the #{name} daemon"
  end

  def status
    if running?
      "running"
    else
      "stopped"
    end
  end

  def logfile
    daemon.output_logfile
  end

  def running?
    daemon.running?
  end

  def system!(step, *args)
    system(*args.map(&:to_s)) || raise("Error with the #{name} daemon during #{step}")
  end

  protected

  def start
    daemon.start
  end

  def stop
    daemon.stop
  end

  def run
    exec(*command)
  end

  def root?
    Process.uid == 0
  end
end
