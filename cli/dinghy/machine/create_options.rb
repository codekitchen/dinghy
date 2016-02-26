module Machine::CreateOptions
  OPTION_NAMES = {
    'virtualbox' => {
      memory: '--virtualbox-memory',
      cpus: '--virtualbox-cpu-count',
      disk: '--virtualbox-disk-size',
      no_share: '--virtualbox-no-share',
    }.freeze,

    'vmwarefusion' => {
      memory: '--vmwarefusion-memory-size',
      cpus: '--vmwarefusion-cpu-count',
      disk: '--vmwarefusion-disk-size',
      no_share: '--vmwarefusion-no-share',
    }.freeze,

    'xhyve' => {
      memory: '--xhyve-memory-size',
      cpus: '--xhyve-cpu-count',
      disk: '--xhyve-disk-size',
      # No shared folders are created on xhyve by default
    }.freeze,
  }.freeze

  def self.generate(provider, options)
    flags = OPTION_NAMES[provider]
    [
      flags[:memory], (options['memory'] || MEM_DEFAULT).to_s,
      flags[:cpus], (options['cpus'] || CPU_DEFAULT).to_s,
      flags[:disk], (options['disk'] || DISK_DEFAULT).to_s,
      flags[:no_share],
    ].compact
  end
end
