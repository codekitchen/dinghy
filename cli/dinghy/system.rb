module System
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