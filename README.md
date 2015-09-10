# dinghy

Docker on OS X with batteries included, aimed at making a more pleasant local development experience.
Runs on top of [docker-machine](https://github.com/docker/machine).

  * Faster volume sharing using NFS rather than built-in virtualbox/vmware file shares. A medium-sized Rails app boots in 5 seconds, rather than 30 seconds using vmware file sharing, or 90 seconds using virtualbox file sharing.
  * Filesystem events work on mounted volumes. Edit files on your host, and see guard/webpack/etc pick up the changes immediately.
  * Easy access to running containers using built-in DNS and HTTP proxy.

Eventually `docker-machine` may have a rich enough plugin system that dinghy can
just become a plugin to `docker-machine`. For now, dinghy runs as a wrapper
around `docker-machine`, shelling out to create the VM and using `launchd` to
start the various services such as NFS and DNS.

## upgrading from vagrant

If you previously used a version of Dinghy that ran on top of Vagrant, [read this](UPGRADE_FROM_VAGRANT.md).

## install

First the prerequisites:

1. OS X Yosemite (10.10) (Mavericks has a known issue, see [#6](https://github.com/codekitchen/dinghy/issues/6))
1. [Homebrew](https://github.com/Homebrew/homebrew)
1. Either [VirtualBox](https://www.virtualbox.org) or [VMware Fusion](http://www.vmware.com/products/fusion).

If using VirtualBox, version 5.0+ is strongly recommended, and you'll need the
[VirtualBox Expansion Pack](https://www.virtualbox.org/wiki/Downloads)
installed.

Then:

    $ brew install --HEAD https://github.com/codekitchen/dinghy/raw/latest/dinghy.rb

This will install the `docker` client and `docker-machine` using Homebrew, as well.

You can specify provider (virtualbox or vmware), memory and CPU options when creating the VM. See available options:

    $ dinghy help create

Then create the VM and start services with:

    $ dinghy create --provider virtualbox

Once the VM is up, you'll get instructions to add some Docker-related
environment variables, so that your Docker client can contact the Docker
server inside the VM. I'd suggest adding these to your .bashrc or
equivalent.

Sanity check!

    $ docker run -it redis

## DNS

Dinghy installs a DNS server listening on the private interface, which
resolves \*.docker to the Dinghy VM. For instance, if you have a running
container that exposes port 3000 to the host, and you like to call it
`myrailsapp`, you can connect to it at `myrailsapp.docker` port 3000, e.g.
`http://myrailsapp.docker:3000/` or `telnet myrailsapp.docker 3000`.

## HTTP proxy

Dinghy will run a HTTP proxy inside a docker container in
the VM, giving you easy access to web apps running in other containers.
This uses the excellent [nginx-proxy](https://github.com/jwilder/nginx-proxy)
docker tool.

The proxy will take a few moments to download the first time you launch the VM.

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
doesn't even listen on other interfaces, for example).

## upgrading

To update Dinghy itself, run:

    $ brew reinstall --HEAD https://github.com/codekitchen/dinghy/raw/latest/dinghy.rb

To update the Docker VM, run:

    $ dinghy upgrade

This will run `docker-machine upgrade` and then restart the dinghy services.

### prereleases

You can install Dinghy's master branch with:

    $ brew reinstall --HEAD https://github.com/codekitchen/dinghy/raw/master/dinghy.rb

This branch may be less stable, so this isn't recommended in general.

## built on

 - https://github.com/docker/machine
 - https://github.com/markusn/unfs3
 - https://github.com/Homebrew/homebrew
 - http://www.thekelleys.org.uk/dnsmasq/doc.html
 - https://github.com/jwilder/nginx-proxy
