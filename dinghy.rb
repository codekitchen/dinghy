require 'formula'

DINGHY_VERSION='4.0.4'

class Dinghy < Formula
  homepage 'https://github.com/codekitchen/dinghy'
  url  'https://github.com/codekitchen/dinghy.git', tag: "v#{DINGHY_VERSION}"
  head 'https://github.com/codekitchen/dinghy.git', branch: :master
  version DINGHY_VERSION

  depends_on 'docker'
  depends_on 'docker-machine'
  depends_on 'unfs3'
  depends_on 'dnsmasq'

  def install
    bin.install "bin/dinghy"
    bin.install "bin/_dinghy_command"
    prefix.install "cli"
  end

  def caveats; <<-EOS.undent
    Run `dinghy create` to create the VM, then `dinghy up` to bring up the VM and services.
    EOS
  end
end
