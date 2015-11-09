require 'pathname'
require 'fileutils'

MEM_DEFAULT=2048
CPU_DEFAULT=1
DISK_DEFAULT=20_000

if ENV['CI'] == 'true'
  BREW = Pathname.new('/usr/local')
else
  BREW = Pathname.new(`brew --prefix`.strip)
end

# makes local dev easier
if $0 =~ /bin\/_dinghy_command/ || $0 =~ /rspec/
  DINGHY = Pathname.new(File.expand_path("../..", File.dirname(__FILE__)))
  VAR = Pathname.new(File.expand_path("../../local/var", File.dirname(__FILE__)))
else
  DINGHY = BREW+"opt/dinghy"
  VAR = BREW+"var/dinghy"
end
HOME = Pathname.new(ENV.fetch("HOME"))
HOME_DINGHY = HOME+'.dinghy'
unless VAR.directory?
  FileUtils.mkdir_p VAR
end
