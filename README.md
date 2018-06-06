# dinghy

Docker on OS X with batteries included, aimed at making a more pleasant local development experience.
Runs on top of [docker-machine](https://github.com/docker/machine).

  * Faster volume sharing using NFS rather than built-in virtualbox/vmware file shares. A medium-sized Rails app boots in 5 seconds, rather than 30 seconds using vmware file sharing, or 90 seconds using virtualbox file sharing.
  * Filesystem events work on mounted volumes. Edit files on your host, and see guard/webpack/etc pick up the changes immediately.
  * Easy access to running containers using built-in DNS and HTTP proxy.

Dinghy creates its own VM using `docker-machine`, it will not modify your existing `docker-machine` VMs.

Eventually `docker-machine` may have a rich enough plugin system that dinghy can
just become a plugin to `docker-machine`. For now, dinghy runs as a wrapper
around `docker-machine`, shelling out to create the VM and using `launchd` to
start the various services such as NFS and DNS.

## FAQ and solutions to common problems

Before filing an issue, see the [FAQ](FAQ.md).

## upgrading from vagrant

If you previously used a version of Dinghy that ran on top of Vagrant, [read this](UPGRADE_FROM_VAGRANT.md).

## install

First the prerequisites:

1. OS X Yosemite (10.10) or higher
1. [Homebrew](https://github.com/Homebrew/homebrew)
1. Docker and Docker Machine. These can either be installed with Homebrew (`brew install docker docker-machine`), or using a package such as the Docker Toolbox.
1. A Virtual Machine provider for Docker Machine. Currently supported options are:
    * [xhyve](http://www.xhyve.org/) installed with [docker-machine-driver-xhyve](https://github.com/zchee/docker-machine-driver-xhyve#install).
    * [VirtualBox](https://www.virtualbox.org). Version 5.0+ is strongly recommended.
    * [VMware Fusion](http://www.vmware.com/products/fusion).
    * [Parallels](https://www.parallels.com/products/desktop/) installed with [docker-machine-parallels](https://github.com/Parallels/docker-machine-parallels).

Then:

    $ brew tap codekitchen/dinghy
    $ brew install dinghy

You will need to install `docker` and `docker-machine` as well, either via Homebrew or the official Docker package downloads. To install with Homebrew:

    $ brew install docker docker-machine

You can specify provider (`virtualbox`, `vmware`, `xhyve` or `parallels`), memory and CPU options when creating the VM. See available options:

    $ dinghy help create

Then create the VM and start services with:

    $ dinghy create --provider virtualbox

Once the VM is up, you'll get instructions to add some Docker-related
environment variables, so that your Docker client can contact the Docker
server inside the VM. I'd suggest adding these to your .bashrc or
equivalent.

Sanity check!

    $ docker run -it redis

## CLI Usage

```bash
$ dinghy help
Commands:
  dinghy create          # create the docker-machine VM
  dinghy destroy         # stop and delete all traces of the VM
  dinghy halt            # stop the VM and services
  dinghy help [COMMAND]  # Describe available commands or one specific command
  dinghy ip              # get the VM's IP address
  dinghy restart         # restart the VM and services
  dinghy shellinit       # returns env variables to set, should be run like $(dinghy shellinit)
  dinghy ssh [args...]   # ssh to the VM
  dinghy status          # get VM and services status
  dinghy up              # start the Docker VM and services
  dinghy upgrade         # upgrade the boot2docker VM to the newest available
  dinghy version         # display dinghy version
```

## DNS

Dinghy installs a DNS server listening on the private interface, which
resolves \*.docker to the Dinghy VM. For instance, if you have a running
container that exposes port 3000 to the host, and you like to call it
`myrailsapp`, you can connect to it at `myrailsapp.docker` port 3000, e.g.
`http://myrailsapp.docker:3000/` or `telnet myrailsapp.docker 3000`.

You can also connect back to your host OS X machine from within a docker
container using the hostname `hostmachine.docker`. This connects to the virtual
network interface, so any services running on the host machine that you want
reachable from docker will have to be listening on this interface.

## HTTP proxy

Dinghy will run a HTTP proxy inside a docker container in the VM, giving you
easy access to web apps running in other containers.

For docker-compose projects, hostnames will be automatically generated based on
the project and service names. For instance, a "web" service in a "myapp"
docker-compose project will be automatically made available at
http://web.myapp.docker

Hostnames can also be manually defined, by setting the `VIRTUAL_HOST`
environment variable on a container.

The proxy has basic SSL support as well.

See the [dinghy-http-proxy documentation](https://github.com/codekitchen/dinghy-http-proxy#dinghy-http-proxy)
for more details on how to configure and use the proxy. 

Advanced proxy configuration can be placed in a file at ```HOME/.dinghy/proxy.conf```. Details can be found in jwilder's [nginx-proxy](https://github.com/jwilder/nginx-proxy#custom-nginx-configuration) project.



## Preferences

Dinghy creates a preferences file under ```HOME/.dinghy/preferences.yml```, which can be used to override default options. This is an example of the default generated preferences:

```
:preferences:
  :proxy_disabled: false
  :fsevents_disabled: false
  :create:
    provider: virtualbox
```

If you want to override the Dinghy machine name (e.g. to change it to 'default' so it can work with Kitematic), it can be changed here. First, destroy your current dinghy VM and then add the following to your preferences.yml file:

```
:preferences:
.
.
.
  :machine_name: default
```

Same goes for the default Dinghy dns resolver '\*.docker' it can be changed to '\*.dev' for example:

```
:preferences:
.
.
.
  :dinghy_domain: dev
```

## A note on NFS sharing

Dinghy shares your home directory (`/Users/<you>`) over NFS, using a
private network interface between your host machine and the Dinghy
Docker Host. This sharing is done using a separate NFS daemon, not the
system NFS daemon.

Be aware that there isn't a lot of security around NFSv3 file shares.
We've tried to lock things down as much as possible (this NFS daemon
doesn't even listen on other interfaces, for example).

### Custom NFS Mount Location

You can change the shared folder by setting the `DINGHY_HOST_MOUNT_DIR` and `DINGHY_GUEST_MOUNT_DIR` environment variables before starting the dinghy VM. Usually you'll want to set both vars to the same value. For instance if you want to share `/code/projects` over NFS rather than `/Users/<you>`, in bash:

```bash
$ dinghy halt
$ export DINGHY_HOST_MOUNT_DIR=/code/projects
$ export DINGHY_GUEST_MOUNT_DIR=/code/projects
$ dinghy up
```

There is an open issue for persisting this in the `~/.dinghy/preferences.yml` file, and allowing multiple dirs to be exported: https://github.com/codekitchen/dinghy/issues/169

## Upgrading

If you didn't originally install Dinghy as a tap, you'll need to switch to the
tap to pull in the latest release:

    $ brew tap codekitchen/dinghy

To update Dinghy itself, run:

    $ dinghy halt
    $ brew upgrade dinghy unfs3
    $ dinghy up

To update the Docker VM, run:

    $ dinghy upgrade

This will run `docker-machine upgrade` and then restart the dinghy services.

### Prereleases

You can install Dinghy's master branch with:

    $ dinghy halt
    $ brew reinstall --HEAD dinghy
    $ dinghy up

This branch may be less stable, so this isn't recommended in general.

## Built on

 - https://github.com/docker/machine
 - https://github.com/unfs3/unfs3
 - https://github.com/Homebrew/homebrew
 - http://www.thekelleys.org.uk/dnsmasq/doc.html
 - https://github.com/jwilder/nginx-proxy
