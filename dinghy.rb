require 'formula'

class Dinghy < Formula
  homepage 'https://github.com/codekitchen/dinghy'
  # TODO: grab the specified version tag
  url 'https://github.com/codekitchen/dinghy.git', :branch => :latest
  head 'https://github.com/codekitchen/dinghy.git', :branch => :master
  version '1.3.0-4'

  depends_on 'docker'
  depends_on 'unfs3'

  def install
    inreplace("dinghy-nfs-exports") do |s|
      s.gsub!("%HOME%", ENV.fetch("HOME"))
    end

    # Not using the normal homebrew plist infrastructure here, since dinghy
    # controls the loading and unloading of its own plist.
    inreplace("dinghy.unfs.plist") do |s|
      s.gsub!("%PREFIX%", HOMEBREW_PREFIX)
      s.gsub!("%ETC%", prefix/"etc")
    end

    (prefix/"etc").install "dinghy-nfs-exports", "dinghy.unfs.plist"

    FileUtils.mkdir_p(var/"dinghy/vagrant")
    FileUtils.cp("vagrant/Vagrantfile", var/"dinghy/vagrant/Vagrantfile")

    bin.install "bin/dinghy"
    prefix.install "cli"
  end

  def caveats; <<-EOS.undent
    Run `dinghy up` to bring up the VM and NFS service.
    EOS
  end
end
