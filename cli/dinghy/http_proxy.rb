require 'stringio'

require 'dinghy/vagrant'

# we ssh in, so this succeeds even if the env vars haven't been set yet
class HttpProxy
  CONTAINER_NAME = "dinghy_http_proxy"

  def up
    puts "Starting the HTTP proxy"
    capture_output do
      Vagrant.new.ssh("docker rm -f #{CONTAINER_NAME}") rescue nil
    end
    Vagrant.new.ssh("docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock --name #{CONTAINER_NAME} jwilder/nginx-proxy")
  end

  def status
    output, _ = capture_output do
      Vagrant.new.ssh("docker inspect -f '{{ .State.Running }}' #{CONTAINER_NAME}")
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
