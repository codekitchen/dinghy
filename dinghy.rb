require 'formula'

DINGHY_VERSION='3.1.1'

class Dinghy < Formula
  homepage 'https://github.com/codekitchen/dinghy'
  url  'https://github.com/codekitchen/dinghy.git', tag: "v#{DINGHY_VERSION}"
  head 'https://github.com/codekitchen/dinghy.git', branch: :machine
  version DINGHY_VERSION

  attr_reader :user_home_dir

  def initialize(*a, &b)
    @user_home_dir = ENV.fetch("HOME")
    super
  end

  depends_on 'docker'
  depends_on 'docker-machine'
  depends_on 'unfs3'
  depends_on 'dnsmasq'

  def install
    inreplace("dinghy-nfs-exports") do |s|
      s.gsub!("%HOME%", user_home_dir)
      s.gsub!("%UID%", Process.uid.to_s)
      s.gsub!("%GID%", Process.gid.to_s)
    end

    # Install nfs exports file to ~/.dinghy if it is missing
    unless(File.file?("#{user_home_dir}/.dinghy/dinghy-nfs-exports"))
        FileUtils.cp("dinghy-nfs-exports", "#{user_home_dir}/.dinghy")
    end

    bin.install "bin/dinghy"
    prefix.install "cli"
  end

  def caveats; <<-EOS.undent
    Run `dinghy up` to bring up the VM and services.
    EOS
  end
end
