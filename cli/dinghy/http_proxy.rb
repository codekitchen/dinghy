require 'stringio'

require 'dinghy/machine'
require 'dinghy/constants'

class HttpProxy
  CONTAINER_NAME = "dinghy_http_proxy"
  IMAGE_NAME = "codekitchen/dinghy-http-proxy:2.0.4"

  attr_reader :machine

  def initialize(machine, dinghy_domain)
    @machine = machine
    @dinghy_domain = dinghy_domain
  end

  def up
    puts "Starting the HTTP proxy"
    System.capture_output do
      docker.system("rm", "-fv", CONTAINER_NAME)
    end
    docker.system("run", "-d",
      "-p", "80:80",
      "-p", "443:443",
      "-v", "/var/run/docker.sock:/tmp/docker.sock",
      "-v", Dinghy.home_dinghy.to_s+"/certs:/etc/nginx/certs",
      "-e", "CONTAINER_NAME=#{CONTAINER_NAME}",
      "-e", "DOMAIN_TLD=#{@dinghy_domain}",
      "--name", CONTAINER_NAME, IMAGE_NAME)
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
