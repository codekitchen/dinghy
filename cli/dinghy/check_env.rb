require 'dinghy/constants'

class CheckEnv
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
      "DOCKER_HOST" => "tcp://127.0.0.1:2376",
      "DOCKER_CERT_PATH" => "#{HOME}/.dinghy/certs",
      "DOCKER_TLS_VERIFY" => "1",
    }
  end

  def print
    expected.each { |name,value| puts "    export #{name}=#{value}" }
  end

  def set?
    expected.all? { |name,value| ENV[name] == value }
  end
end
