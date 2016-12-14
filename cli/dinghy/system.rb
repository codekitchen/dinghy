module System
  class Failure < ::RuntimeError
  end

  def self.system_print(*args)
    Kernel.system(*args)
    if self.command_failed?
      raise(Failure, "Failure calling `#{args.join(' ')}`")
    end
  end

  def self.system(*args)
    out, err = self.capture_output {
      Kernel.system(*args)
    }
    if self.command_failed?
      $stderr.puts err
      raise(Failure, "Failure calling `#{args.join(' ')}`")
    end
    out
  end

  def self.capture_output
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

  def self.command_failed?
    !$?.success?
  end
end
