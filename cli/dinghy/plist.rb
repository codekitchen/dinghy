require 'dinghy/constants'

module Plist
  def up
    halt

    puts starting_message
    system!("linking", "cp", plist_path.to_s, plist_install_path.to_s)
    system!("launching", "launchctl", "load", plist_install_path.to_s)
  end

  def halt
    if File.exist?(plist_install_path)
      puts stopping_message
      system!("stopping", "launchctl", "unload", plist_install_path.to_s)
      system!("removing", "rm", plist_install_path.to_s)
    end
  end

  def plist_install_path
    "#{HOME}/Library/LaunchAgents/#{plist_name}"
  end

  def plist_path
    DINGHY+plist_name
  end

  def system!(step, *args)
    system(*args.map(&:to_s)) || raise("Error with the #{name} daemon during #{step}")
  end

  def starting_message
    "Starting #{name} daemon"
  end

  def stopping_message
    "Stopping #{name} daemon"
  end
end

module RootPlist
  include Plist

  def plist_install_path
    "/Library/LaunchAgents/#{plist_name}"
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
