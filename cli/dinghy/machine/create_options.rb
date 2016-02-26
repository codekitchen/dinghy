module Machine::CreateOptions
  OPTION_NAMES = {
    'virtualbox' => {
      memory: '--virtualbox-memory',
      cpus: '--virtualbox-cpu-count',
      disk: '--virtualbox-disk-size',
      no_share: '--virtualbox-no-share',
      boot2docker_url: '--virtualbox-boot2docker-url'
    }.freeze,

    'vmwarefusion' => {
      memory: '--vmwarefusion-memory-size',
      cpus: '--vmwarefusion-cpu-count',
      disk: '--vmwarefusion-disk-size',
      no_share: '--vmwarefusion-no-share',
      boot2docker_url: '--vmwarefusion-boot2docker-url'
    }.freeze,

    'xhyve' => {
      memory: '--xhyve-memory-size',
      cpus: '--xhyve-cpu-count',
      disk: '--xhyve-disk-size',
      # No shared folders are created on xhyve by default
      boot2docker_url: '--xhyve-boot2docker-url'
    }.freeze,

    'parallels' => {
      memory: '--parallels-memory',
      cpus: '--parallels-cpu-count',
      disk: '--parallels-disk-size',
      no_share: '--parallels-no-share',
      boot2docker_url: '--parallels-boot2docker-url'
    }.freeze
  }.freeze

  def self.generate(provider, options)
    flags = OPTION_NAMES[provider]
    [
      flags[:memory], (options['memory'] || MEM_DEFAULT).to_s,
      flags[:cpus], (options['cpus'] || CPU_DEFAULT).to_s,
      flags[:disk], (options['disk'] || DISK_DEFAULT).to_s,
      flags[:no_share]
    ].compact.tap do |create_options|
      unless options['boot2docker_url'].nil?
        create_options << flags[:boot2docker_url]
        create_options << options['boot2docker_url'].to_s
      end
    end
  end
end
