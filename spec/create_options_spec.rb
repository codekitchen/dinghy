RSpec.describe Machine::CreateOptions do
  subject { described_class }
  it 'generates default options' do
    expect(subject.generate('virtualbox', {})).to eq([
      '--virtualbox-memory', MEM_DEFAULT.to_s,
      '--virtualbox-cpu-count', CPU_DEFAULT.to_s,
      '--virtualbox-disk-size', DISK_DEFAULT.to_s,
      '--virtualbox-no-share',
    ])
  end

  it 'generates with passed options' do
    opts = { 'memory' => 4096, 'disk' => 40000, 'boot2docker_url' => 'alternate' }
    expect(subject.generate('vmwarefusion', opts)).to eq([
      '--vmwarefusion-memory-size', '4096',
      '--vmwarefusion-cpu-count', CPU_DEFAULT.to_s,
      '--vmwarefusion-disk-size', '40000',
      '--vmwarefusion-no-share',
      '--vmwarefusion-boot2docker-url', 'alternate'
    ])
  end
end
