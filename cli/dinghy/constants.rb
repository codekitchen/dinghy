require 'pathname'
require 'fileutils'

MEM_DEFAULT=2048
CPU_DEFAULT=1
DISK_DEFAULT=20_000

# makes local dev easier
if $0 == "bin/dinghy" || $0 =~ /rspec/
  BREW = '/usr/local'
  DINGHY = Pathname.new(File.expand_path("../..", File.dirname(__FILE__)))
else
  BREW = Pathname.new(`brew --prefix`.strip)
  DINGHY = BREW+"opt/dinghy/etc"
end
HOME = Pathname.new(ENV.fetch("HOME"))
HOME_DINGHY = HOME+'.dinghy'