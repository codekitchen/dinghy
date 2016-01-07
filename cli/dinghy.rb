module Dinghy
  def self.run_checks
    create_dinghy_dir
    docker_cmd_checks
    version_check
  end

  REQUIRED_VERSIONS = {
    'docker' => Gem::Version.new("1.8.1"),
    'docker-machine' => Gem::Version.new("0.5.5"),
  }

  def self.create_dinghy_dir
    # Create the .dinghy dir if it is missing
    unless HOME_DINGHY.directory?
      HOME_DINGHY.mkdir
    end
  end

  def self.docker_cmd_checks
    recommendation = "command could not be found, please install.\nBrew [brew install docker; brew install docker-machine] or The Docker Toolbox [https://www.docker.com/docker-toolbox] are two great options!"

    unless run_and_check("which docker")
      fail "'docker' #{recommendation}"
    end

    unless run_and_check("which docker-machine")
      fail "'docker-machine' #{recommendation}"
    end
  end

  def self.version_check
    REQUIRED_VERSIONS.each do |command, required_version|
      installed_version = version(command)
      if installed_version < required_version
        fail "#{command} version #{installed_version} is too old, please upgrade to version #{required_version}"
      end
    end
  end

  def self.fail(msg)
    $stderr.puts msg
    exit(2)
  end

  def self.run_and_check(command)
    _ = System.capture_output { system(command) }
    !System.command_failed?
  end

  def self.version(command)
    text, _ = System.capture_output { system(command, "--version") }
    if System.command_failed?
      raise("Could not check #{command} --version, is it installed?")
    end
    version = text.match(%r{\b\d+\.\d+\.\d+})[0]
    if version.empty?
      raise("Could not check #{command} --version, is it installed?")
    end
    Gem::Version.new(version)
  end
end
