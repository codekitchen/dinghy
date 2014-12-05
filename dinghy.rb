require 'formula'

class Dinghy < Formula
  homepage 'https://github.com/codekitchen/dinghy'
  # TODO: grab the specified version tag
  url 'https://github.com/codekitchen/dinghy.git', :branch => :latest
  head 'https://github.com/codekitchen/dinghy.git', :branch => :master
  version "2.0.2"

  depends_on 'docker'
  depends_on 'unfs3'
  depends_on 'dnsmasq'

  def install
    inreplace("dinghy-nfs-exports") do |s|
      s.gsub!("%HOME%", ENV.fetch("HOME"))
    end

    # Not using the normal homebrew plist infrastructure here, since dinghy
    # controls the loading and unloading of its own plist.
    inreplace(["dinghy.unfs.plist", "dinghy.dnsmasq.plist"]) do |s|
      s.gsub!("%PREFIX%", HOMEBREW_PREFIX)
      s.gsub!("%ETC%", prefix/"etc", false)
    end

    (prefix/"etc").install "dinghy-nfs-exports", "dinghy.unfs.plist", "dinghy.dnsmasq.plist"

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
