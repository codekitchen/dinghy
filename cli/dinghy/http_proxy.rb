require 'stringio'

require 'dinghy/machine'

class HttpProxy
  CONTAINER_NAME = "dinghy_http_proxy"
  IMAGE_NAME = "codekitchen/dinghy-http-proxy:2.0.2"

  attr_reader :machine

  def initialize(machine)
    @machine = machine
  end

  def up
    puts "Starting the HTTP proxy"
    System.capture_output do
      docker.system("rm", "-fv", CONTAINER_NAME)
    end
    docker.system("run", "-d", "-p", "80:80", "-v", "/var/run/docker.sock:/tmp/docker.sock", "-v", "/usr/local/bin/docker:/usr/local/bin/docker", "-e", "CONTAINER_NAME=#{CONTAINER_NAME}", "--name", CONTAINER_NAME, IMAGE_NAME)
  end

  def status
    return "stopped" if !machine.running?

    output, _ = System.capture_output do
      docker.system("inspect", "-f", "{{ .State.Running }}", CONTAINER_NAME)
    end

    if output.strip == "true"
      "running"
    else
      "stopped"
    end
  end

  private

  def docker
    @docker ||= Docker.new(machine)
  end
end
