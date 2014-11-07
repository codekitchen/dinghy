require 'formula'

class Dinghy < Formula
  homepage 'https://github.com/codekitchen/dinghy'
  # TODO: grab the specified version tag
  url 'https://github.com/codekitchen/dinghy.git', :branch => :latest
  head 'https://github.com/codekitchen/dinghy.git', :branch => :master
  version '1.3.0-3'

  depends_on 'docker'
  depends_on 'unfs3'

  def install
    inreplace("dinghy-nfs-exports") do |s|
      s.gsub!("%HOME%", ENV.fetch("HOME"))
      s.gsub!("%UID%", Process.uid.to_s)
      s.gsub!("%GID%", Process.gid.to_s)
    end

    # Not using the normal homebrew plist infrastructure here, since dinghy
    # controls the loading and unloading of its own plist.
    inreplace("dinghy.unfs.plist") do |s|
      s.gsub!("%PREFIX%", HOMEBREW_PREFIX)
      s.gsub!("%ETC%", prefix/"etc")
    end
    inreplace("dinghy.ntp.plist") do |s|
      s.gsub!("%BIN%", bin)
    end

    (prefix/"etc").install "dinghy-nfs-exports", "dinghy.unfs.plist", "dinghy.ntp.plist"
    FileUtils.mkdir_p(var/"dinghy/vagrant")
    FileUtils.cp("vagrant/Vagrantfile", var/"dinghy/vagrant/Vagrantfile")
    bin.install "dinghy"
  end

  def caveats; <<-EOS.undent
    Run `dinghy up` to bring up the VM and NFS service.
    EOS
  end
end
