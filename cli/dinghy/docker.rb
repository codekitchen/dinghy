class Docker
  attr_reader :machine

  def initialize(machine)
    @machine = machine
  end

  def system(*command)
    set_env!
    Kernel.system("docker", *command)
  end

  protected

  def set_env!
    CheckEnv.new(machine).expected.each { |k,v| ENV[k] = v }
  end
end