RSpec.describe HttpProxy do
  let(:machine) { double(:machine, vm_ip: '192.168.99.100') }
  let(:proxy) { described_class.new(machine, nil) }

  it 'defaults to `docker` as domain when no preference exists' do
    expect(proxy.dinghy_domain).to eq "docker"
    expect(proxy.resolver_file).to eq Pathname.new("/etc/resolver/docker")
    expect(proxy.send(:run_args)).to be_include "DOMAIN_TLD=docker"
  end

  it 'sets the domain to the one set in the preferences' do
    proxy.dinghy_domain = "dev"
    expect(proxy.dinghy_domain).to eq "dev"
    expect(proxy.resolver_file).to eq Pathname.new("/etc/resolver/dev")
    expect(proxy.send(:run_args)).to be_include "DOMAIN_TLD=dev"
  end
end
