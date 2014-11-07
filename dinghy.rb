require 'formula'

class Dinghy < Formula
  homepage 'https://github.com/codekitchen/dinghy'
  # TODO: grab the specified version tag
  url 'https://github.com/codekitchen/dinghy.git'
  version '1.3.0-2'

  depends_on 'docker'
  depends_on 'unfs3'

  def install
    etc.install "dinghy-nfs-exports"
    inreplace "#{etc}/dinghy-nfs-exports" do |s|
      s.gsub!("%HOME%", ENV.fetch("HOME"))
      s.gsub!("%UID%", Process.uid.to_s)
      s.gsub!("%GID%", Process.gid.to_s)
    end

    (var/"dinghy").install "vagrant", "dinghy.unfs.plist"

    # Not using the normal homebrew plist infrastructure here, since dinghy
    # controls the loading and unloading of its own plist.
    inreplace "#{var}/dinghy/dinghy.unfs.plist" do |s|
      s.gsub!("%PREFIX%", HOMEBREW_PREFIX)
      s.gsub!("%ETC%", etc)
    end

    bin.install "dinghy"
  end

  def caveats; <<-EOS.undent
    Run `dinghy up` to bring up the VM and NFS service.
    EOS
  end
end
