RSpec.describe Dnsmasq do
  let(:machine) { double(:machine, vm_ip: '192.168.99.100') }
  let(:dnsmasq) { Dnsmasq.new(machine, nil) }

  it 'defaults to `docker` as domain when no preference exists' do
    expect(dnsmasq.dinghy_domain).to eq "docker"
    expect(dnsmasq.resolver_file).to eq Pathname.new("/etc/resolver/docker")
    expect(dnsmasq.send(:command).last).to eq "--address=/.docker/192.168.99.100"
  end

  it 'sets the domain to the one set in the preferences' do
    dnsmasq.dinghy_domain = "dev"
    expect(dnsmasq.dinghy_domain).to eq "dev"
    expect(dnsmasq.resolver_file).to eq Pathname.new("/etc/resolver/dev")
    expect(dnsmasq.send(:command).last).to eq "--address=/.dev/192.168.99.100"
  end
end
