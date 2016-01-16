RSpec.describe Dnsmasq do
  let(:dnsmasq_instance) {
    # Mocking the machine class
    machine = Class.new do
      def vm_ip 
        "192.168.99.100"
      end
    end
    Dnsmasq.new(machine.new)
  }

  it 'defaults to `docker` as domain when no preference exists' do
    expect(dnsmasq_instance.dinghy_domain).to eq "docker"
    expect(dnsmasq_instance.resolver_file).to eq Pathname.new("/etc/resolver/docker")
    expect(dnsmasq_instance.send(:command).last).to eq "--address=/.docker/192.168.99.100"
  end
  
  it 'sets the domain to the one set in the preferences' do
    dnsmasq_instance.dinghy_domain = "dev"
    expect(dnsmasq_instance.dinghy_domain).to eq "dev"
    expect(dnsmasq_instance.resolver_file).to eq Pathname.new("/etc/resolver/dev")
    expect(dnsmasq_instance.send(:command).last).to eq "--address=/.dev/192.168.99.100"
  end
end
