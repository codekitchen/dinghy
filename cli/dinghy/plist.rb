require 'erb'

require 'dinghy/constants'

module Plist
  def up
    halt

    puts starting_message
    system!("preparing", "mkdir", "-p", File.dirname(plist_install_path.to_s))
    system!("linking", "cp", plist_path.to_s, plist_install_path.to_s)
    system!("launching", "launchctl", "load", "-w", plist_install_path.to_s)
  end

  def halt
    if File.exist?(plist_install_path)
      puts stopping_message
      system!("stopping", "launchctl", "unload", "-w", plist_install_path.to_s)
      system!("removing", "rm", plist_install_path.to_s)
    end
  end

  def plist_install_path
    "#{HOME}/Library/LaunchAgents/#{plist_name}"
  end

  def prepared_plist
    ERB.new(plist_body).result(binding)
  end

  def plist_path
    if !@tmpfile
      @tmpfile = Tempfile.new(["dinghy", ".plist"])
      @tmpfile.write(prepared_plist)
      @tmpfile.flush
    end
    @tmpfile.path
  end

  def system!(step, *args)
    system(*args.map(&:to_s)) || raise("Error with the #{name} daemon during #{step}")
  end

  def starting_message
    "Starting the #{name} daemon"
  end

  def stopping_message
    "Stopping the #{name} daemon"
  end
end

module RootPlist
  include Plist

  def plist_install_path
    "/Library/LaunchDaemons/#{plist_name}"
  end

  def system!(step, *args)
    super(step, "sudo", *args)
  end

  def starting_message
    "Starting #{name} daemon, this will require sudo"
  end

  def stopping_message
    "Stopping #{name} daemon, this will require sudo"
  end
end
