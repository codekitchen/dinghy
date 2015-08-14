require 'pathname'
require 'fileutils'

MEM_DEFAULT=2048
CPU_DEFAULT=1

BREW = Pathname.new(`brew --prefix`.strip)
# makes local dev easier
if $0 == "bin/dinghy"
  DINGHY = Pathname.new(File.expand_path("../..", File.dirname(__FILE__)))
else
  DINGHY = BREW+"opt/dinghy/etc"
end
HOME = ENV.fetch("HOME")
