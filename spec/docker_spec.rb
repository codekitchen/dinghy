RSpec.describe Docker do
  let(:machine) { double('Machine') }
  let(:check_env) {
    double('CheckEnv',
      expected: { 'DOCKER_HOST' => 'realhost' }
    )
  }
  subject { described_class.new(machine, check_env) }

  describe '#system' do
    it 'preserves the original environment' do
      expect(Kernel).to receive(:system).with("docker", "ps").and_return "zero"
      ENV['DOCKER_HOST'] = 'myhost'
      expect(subject.system("ps")).to eq('zero')
      expect(ENV['DOCKER_HOST']).to eq('myhost')
    end
  end
end