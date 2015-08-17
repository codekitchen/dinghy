require 'stringio'

require 'dinghy/machine'

# we ssh in, so this succeeds even if the env vars haven't been set yet
class HttpProxy
  CONTAINER_NAME = "dinghy_http_proxy"

  attr_reader :machine

  def initialize(machine)
    @machine = machine
  end

  def up
    puts "Starting the HTTP proxy"
    docker = Docker.new(machine)
    capture_output do
      docker.system("rm", "-fv", CONTAINER_NAME)
    end
    docker.system("run", "-d", "-p", "80:80", "-v", "/var/run/docker.sock:/tmp/docker.sock", "--name", CONTAINER_NAME, "codekitchen/dinghy-http-proxy")
  end

  def status
    output, _ = capture_output do
      machine.ssh("docker inspect -f '{{ .State.Running }}' #{CONTAINER_NAME}")
    end

    if output.strip == "true"
      "running"
    else
      "not running"
    end
  rescue # ehhhhhh
    "not running"
  end

  private

  def capture_output
    prev_stdout = $stdout.dup
    prev_stderr = $stderr.dup
    $stdout.reopen(Tempfile.new("stdout"))
    $stderr.reopen(Tempfile.new("stderr"))
    yield
    return $stdout.tap(&:rewind).read, $stderr.tap(&:rewind).read
  ensure
    $stdout.reopen(prev_stdout)
    $stderr.reopen(prev_stderr)
  end
end
