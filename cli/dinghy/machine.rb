require 'dinghy/constants'
require 'json'
require 'shellwords'

class Machine
  attr_reader :machine_name
  alias :name :machine_name

  def initialize(machine_name)
    @machine_name = machine_name || 'dinghy'
  end

  def create(options = {})
    provider = options['provider']

    out, err = System.capture_output {
      system("create", "-d", provider, *CreateOptions.generate(provider, options), machine_name)
    }

    if System.command_failed?
      $stderr.puts err
      raise("There was an error creating the VM.")
    end

    configure_new_machine(provider)
  end

  def up
    unless running?
      out, err = System.capture_output {
        system("start", machine_name)
      }

      if System.command_failed?
        $stderr.puts err
        raise("There was an error bringing up the VM. Dinghy cannot continue.")
      end
    end
  end

  def host_ip
    vm_ip.sub(%r{\.\d+$}, '.1')
  end

  def vm_ip
    inspect_driver['IPAddress']
  end

  def ssh_identity_file_path
    inspect_driver['SSHKeyPath']
  end

  def provider
    inspect['DriverName']
  end

  def store_path
    driver = inspect_driver
    if driver.key?('StorePath')
      File.join(driver['StorePath'], 'machines', driver['MachineName'])
    else
      inspect['StorePath']
    end
  end

  def inspect
    JSON.parse(`docker-machine inspect #{machine_name} 2>/dev/null`)
  end

  def inspect_driver
    output = inspect
    output['Driver']['Driver'] || output['Driver']
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
    # Remove the existing vbox/vmware shared folder. Machine now has flags to
    # skip mounting the share at all, but there's no way to apply the flag to an
    # already-created machine. So we have to continue to do this for older VMs.
    ssh("if [ $(grep -c #{Shellwords.escape('/Users[^/]')} /proc/mounts) -gt 0 ]; then sudo umount /Users || true; fi;")

    ssh("sudo mkdir -p #{unfs.guest_mount_dir}")
    ssh("sudo mount -t nfs #{host_ip}:#{unfs.host_mount_dir} #{unfs.guest_mount_dir} -o nfsvers=3,udp,mountport=#{unfs.port},port=#{unfs.port},nolock,hard,intr")
  end

  def ssh(*command)
    system("ssh", machine_name, *command) || raise("ssh command failed")
  end

  def ssh_exec(*command)
    Kernel.exec("docker-machine", "ssh", machine_name, *command)
  end

  def halt
    system("stop", machine_name)
  end

  def upgrade
    if !running?
      up
    end
    system("upgrade", machine_name)
  end

  def destroy(options = {})
    system(*["rm", (options[:force] ? '--force' : nil), machine_name].compact)
  end

  def created?
    `docker-machine status #{machine_name} 2>&1`
    !System.command_failed?
  end

  def system(*cmd)
    Kernel.system("docker-machine", *cmd)
  end

  def translate_provider(name)
    case name
    when "virtualbox"
      "virtualbox"
    when "vmware", "vmware_fusion", "vmwarefusion", "vmware_desktop"
      "vmwarefusion"
    else
      nil
    end
  end

  protected

  def configure_new_machine(provider)
    if provider == "virtualbox"
      halt
      # force host DNS resolving, so that *.docker resolves inside containers
      Kernel.system("VBoxManage", "modifyvm", machine_name, "--natdnshostresolver1", "on")

      if System.command_failed?
        raise("There was an error configuring the VM.")
      end
      up
    end
  end
end
