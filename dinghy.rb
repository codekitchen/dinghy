require 'formula'

DINGHY_VERSION='3.0.4'

class Dinghy < Formula
  homepage 'https://github.com/codekitchen/dinghy'
  url  'https://github.com/codekitchen/dinghy.git', tag: "v#{DINGHY_VERSION}"
  head 'https://github.com/codekitchen/dinghy.git', branch: :master
  version DINGHY_VERSION

  PLISTS = %w[
    dinghy.unfs.plist
    dinghy.dnsmasq.plist
    dinghy.fsevents_to_vm.plist
  ]

  attr_reader :user_home_dir

  def initialize(*a, &b)
    @user_home_dir = ENV.fetch("HOME")
    super
  end

  depends_on 'docker'
  depends_on 'unfs3'
  depends_on 'dnsmasq'

  def install
    inreplace("dinghy-nfs-exports") do |s|
      s.gsub!("%HOME%", user_home_dir)
      s.gsub!("%UID%", Process.uid.to_s)
      s.gsub!("%GID%", Process.gid.to_s)
    end

    # Not using the normal homebrew plist infrastructure here, since dinghy
    # controls the loading and unloading of its own plists.
    inreplace(PLISTS) do |s|
      s.gsub!("%HOME%", user_home_dir, false)
      s.gsub!("%HOME_DINGHY%", "#{user_home_dir}/.dinghy", false)
      s.gsub!("%HOMEBREW_PREFIX%", HOMEBREW_PREFIX, false)
      s.gsub!("%ETC%", prefix/"etc", false)
    end

    # Install nfs exports file to ~/.dinghy if it is missing
    unless(File.file?("#{user_home_dir}/.dinghy/dinghy-nfs-exports"))
        FileUtils.cp("dinghy-nfs-exports", "#{user_home_dir}/.dinghy")
    end

    # install plits
    (prefix/"etc").install *PLISTS

    FileUtils.mkdir_p(var/"dinghy/vagrant")
    FileUtils.cp("vagrant/Vagrantfile", var/"dinghy/vagrant/Vagrantfile")

    bin.install "bin/dinghy"
    prefix.install "cli"
  end

  def caveats; <<-EOS.undent
    Run `dinghy up` to bring up the VM and services.
    EOS
  end
end
