# This wraps the `docker` binary and ensures that we can use it even if the
# shell doesn't have the necessary ENV vars set.
class Docker
  attr_reader :machine

  def initialize(machine, check_env = nil)
    @machine = machine
    @check_env = check_env || CheckEnv.new(machine)
  end

  def system(*command)
    set_env do
      Kernel.system("docker", *command)
    end
  end

  protected

  # Make sure to restore the old env afterwards, so that CheckEnv can validate
  # the user's environment.
  def set_env
    old_env = {}
    @check_env.expected.each { |k,v| old_env[k] = ENV[k]; ENV[k] = v }
    yield
  ensure
    old_env.each { |k,v| ENV[k] = v }
  end
end