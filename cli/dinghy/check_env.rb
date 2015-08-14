require 'dinghy/constants'

class CheckEnv
  attr_reader :machine

  def initialize(machine)
    @machine = machine
  end

  def run
    if set?
      puts "Your environment variables are already set correctly."
    else
      puts "To connect the Docker client to the Docker daemon, please set:"
      print
    end
  end

  def expected
    {
      "DOCKER_HOST" => "tcp://#{machine.vm_ip}:2376",
      "DOCKER_CERT_PATH" => machine.store_path,
      "DOCKER_TLS_VERIFY" => "1",
      "DOCKER_MACHINE_NAME" => machine.machine_name,
    }
  end

  def print
    expected.each { |name,value| puts "    export #{name}=#{value}" }
  end

  def set?
    expected.all? { |name,value| ENV[name] == value }
  end
end
