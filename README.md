# dinghy

Faster, friendlier Docker on OS X with Vagrant.

## install

First the prerequisites:

1. OS X Yosemite (10.10) (Mavericks has a known issue, see [#6](https://github.com/codekitchen/dinghy/issues/6))
1. [Homebrew](https://github.com/Homebrew/homebrew)
1. [Vagrant](http://vagrantup.com)

Then:

    $ brew install https://github.com/codekitchen/dinghy/raw/latest/dinghy.rb

This will install the Docker client as well, using Homebrew. If you
already have the Docker client installed, you will need to remove it or
upgrade it to version 1.4 or higher. Dinghy will
use your default Vagrant provider, be it VMWare Fusion or Virtual Box,
though that can be overridden with an option:

    $ dinghy help up
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

1. It uses NFS for sharing files with the VM, and with the Docker containers
   inside the VM. boot2docker recently added support for sharing all of
   `/Users` into your VM, but VirtualBox native file sharing is extremely
   slow. It increases our Rails application's bootup time by an order of
   magnitude.

1. Dinghy is built on top of Vagrant, which makes Dinghy itself simpler
   and if you already use Vagrant, allows integration with all of your
   current Vagrant tooling.

1. Support for both VirtualBox and VMWare Fusion (requires the paid Vagrant plugin).

1. Allow setting VM RAM and CPU parameters dynamically on each startup.

1. With vanilla boot2docker VMs on OS X, the clock will get out of synch
   if your computer sleeps with the VM running. Dinghy attempts to solve
   this issue by forcing a periodic NTP sync.

1. Our end goal is to make it as easy to develop with Docker on OS X as
   it is to develop with [pow.cx](http://pow.cx).

## DNS

Dinghy installs a DNS server listening on the private interface, which
resolves \*.docker to the Dinghy VM. For instance, if you have a running
container that exposes port 3000 to the host, and you like to call it
`myrailsapp`, you can connect to it at `myrailsapp.docker` port 3000, e.g.
`http://myrailsapp.docker:3000/` or `telnet myrailsapp.docker 3000`.

## optional HTTP proxy

Dinghy will optionally run a HTTP proxy inside a docker container in
the VM, giving you easy access to web apps running in other containers.
This uses the excellent [nginx-proxy](https://github.com/jwilder/nginx-proxy)
docker tool.

To enable the proxy, run dinghy up with the --proxy option:

    $ dinghy up --proxy

This might take a few minutes the first time, to download the container
image.

Any containers that you want proxied, make sure the `VIRTUAL_HOST`
environment variable is set, either with the `-e` option to docker or
the environment hash in docker-compose. For instance setting
`VIRTUAL_HOST=myrailsapp.docker` will make the container's exposed port
available at `http://myrailsapp.docker/`. If the container exposes more
than one port, set `VIRTUAL_PORT` to the http port number, as well.

See the nginx-proxy documentation for further details.

If you use docker-compose, you can add VIRTUAL_HOST to the environment hash in
`docker-compose.yml`, for instance:

```yaml
web:
  build: .
  ports:
    - "3000:3000"
  environment:
    VIRTUAL_HOST: myrailsapp.docker
```

## a note on NFS sharing

Dinghy shares your home directory (`/Users/<you>`) over NFS, using a
private network interface between your host machine and the Dinghy
Vagrant VM. This sharing is done using a separate NFS daemon, not the
system NFS daemon.

Be aware that there isn't a lot of security around NFSv3 file shares.
We've tried to lock things down as much as possible (this NFS daemon
doesn't even listen on other interfaces, for example). We feel that this
flavor of NFS sharing is safer than Vagrant's built-in solution.

## upgrading

To update Dinghy itself, run:

    $ brew reinstall https://github.com/codekitchen/dinghy/raw/latest/dinghy.rb

To update the Docker VM, run:

    $ dinghy upgrade

This will delete your current VM, so you'll have to re-download docker
image layers. It won't delete any data on the NFS share, though.

### prereleases

You can install Dinghy's master branch with:

    $ brew reinstall --HEAD https://github.com/codekitchen/dinghy/raw/master/dinghy.rb

This branch may be less stable, so this isn't recommended in general.

## built on

 - https://github.com/mitchellh/boot2docker-vagrant-box
 - https://github.com/markusn/unfs3
 - https://github.com/Homebrew/homebrew
 - http://vagrantup.com
 - http://www.thekelleys.org.uk/dnsmasq/doc.html
 - https://github.com/jwilder/nginx-proxy
