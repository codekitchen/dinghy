require 'pathname'
require 'fileutils'

MEM_DEFAULT=2048
CPU_DEFAULT=1

BREW = Pathname.new(`brew --prefix`.strip)
DINGHY = BREW+"opt/dinghy/etc"
VAGRANT = BREW+"var/dinghy/vagrant"
HOST_IP = "192.168.42.1"
VM_IP = "192.168.42.10"
HOME = ENV.fetch("HOME")
