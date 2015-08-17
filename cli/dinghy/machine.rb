require 'dinghy/constants'
require 'json'

class Machine
  def up(options = {})
    if created?
      system("start", machine_name)
    else
      system("create", "-d", provider(options[:provider]), machine_name)
    end

    if command_failed?
      raise("There was an error bringing up the VM. Dinghy cannot continue.")
    end

    Ssh.new(self).write_ssh_config!
  end

  def host_ip
    vm_ip.sub(%r{\.\d+$}, '.1')
  end

  def vm_ip
    inspect['Driver']['IPAddress']
  end

  def provider
    inspect['DriverName']
  end

  def store_path
    inspect['StorePath']
  end

  def inspect
    JSON.parse(`docker-machine inspect #{machine_name} 2>/dev/null`)
  end

  def status
    if created?
      `docker-machine status #{machine_name}`.strip.downcase
    else
      "not created"
    end
  end

  def running?
    status == "running"
  end

  def mount(unfs)
    puts "Mounting NFS #{unfs.guest_mount_dir}"
    # TODO: this shouldn't be hard-coded, and should check that it's currently mounted
    ssh("sudo umount /Users || true")
    ssh("sudo mkdir -p #{unfs.guest_mount_dir}")
    ssh("sudo mount -t nfs #{host_ip}:#{unfs.host_mount_dir} #{unfs.guest_mount_dir} -o nfsvers=3,udp,mountport=19321,port=19321,nolock,hard,intr")
  end

  def ssh(*command)
    Ssh.new(self).run(*command)
  end

  def halt
    system("stop", machine_name)
  end

  def upgrade
    system("upgrade", machine_name)
  end

  def destroy(options = {})
    system(*["rm", (options[:force] ? '--force' : nil), machine_name].compact)
  end

  def created?
    `docker-machine status #{machine_name} 2>&1`
    !command_failed?
  end

  def system(*cmd)
    Kernel.system("docker-machine", *cmd)
  end

  def machine_name
    'dinghy'
  end
  alias :name :machine_name

  protected

  def provider(name)
    case name
    when "virtualbox"
      "virtualbox"
    when "vmware", "vmware_fusion", "vmwarefusion", "vmware_desktop"
      "vmwarefusion"
    when nil
      # TODO: autodetect?
      "virtualbox"
    else
      raise(ArgumentError, "unknown VM provider: #{name}")
    end
  end

  def command_failed?
    !$?.success?
  end
end
