# dinghy

Faster, safer Docker on OS X with Vagrant.

## install

First, install [Homebrew](https://github.com/Homebrew/homebrew) and
[Vagrant](http://vagrantup.com) if you haven't already.

Then:

    $ brew install https://raw.githubusercontent.com/codekitchen/dinghy/latest/dinghy.rb

This will install the Docker client as well, using Homebrew. Dinghy will
use your default Vagrant provider, be it VMWare Fusion or Virtual Box:

    $ dinghy up

Once the VM is up, you'll get instructions to add some Docker-related
environment variables, so that your Docker client can contact the Docker
server inside the VM. I'd suggest adding these to your .bashrc or
equivalent.

Sanity check!

    $ docker run -it redis

## why

As we've begun using Docker more heavily in development on OS X, we've run into
a few issues with the current boot2docker solution. Dinghy builds on
boot2docker, but with some unique features:

1. Dinghy uses NFS for sharing files with the VM, and with the Docker containers
   inside the VM. boot2docker recently added support for sharing all of
   `/Users` into your VM, but VirtualBox native file sharing is extremely
   slow. It increases our Rails application's bootup time by an order of
   magnitude.

1. Dinghy is built on top of Vagrant, which makes Dinghy itself simpler
   and if you already use Vagrant, allows integration with all of your
   current Vagrant tooling.

1. Dinghy supports both VirtualBox and VMWare Fusion (requires the paid Vagrant plugin).

1. Dinghy allows setting VM RAM and CPU parameters dynamically on each startup.

## a note on NFS sharing

Dinghy shares your home directory (`/Users/<you>`) over NFS, using a
private network interface between your host machine and the Dinghy
Vagrant VM. This sharing is done in userspace, as your user, not as root.

Be aware that there isn't a lot of security around NFSv3 file shares.
We've tried to lock things down as much as possible (this NFS daemon
doesn't even listen on other interfaces, for example). We feel that this
flavor of NFS sharing is safer than Vagrant's built-in solution.

## caveats

Containers won't be able to `chown` on volumes shared via NFS. This prevents
the official postgres docker image from working with an NFS volume,
you'll need to use a docker volume local to the VM instead. I'm looking
for ways to fix this.

## built on

 - https://github.com/mitchellh/boot2docker-vagrant-box
 - https://github.com/markusn/unfs3
 - https://github.com/Homebrew/homebrew
 - http://vagrantup.com

## future plans

I plan to maintain and improve dinghy in the short term, but I'd love to
see it eventually obsoleted by further boot2docker development.
