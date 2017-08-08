<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Dinghy FAQ](#dinghy-faq)
  - [The `docker` client gives an SSL error or times out](#the-docker-client-gives-an-ssl-error-or-times-out)
  - [The `docker` client reports errors like `x509: certificate is valid for 192.168.x.y, not 192.168.x.z`](#the-docker-client-reports-errors-like-x509-certificate-is-valid-for-192168xy-not-192168xz)
  - [I'm running into file permissions issues on the NFS mounted volumes](#im-running-into-file-permissions-issues-on-the-nfs-mounted-volumes)
  - [I can't connect to an app running in docker from another VM (commonly to test in IE)](#i-cant-connect-to-an-app-running-in-docker-from-another-vm-commonly-to-test-in-ie)
  - [I want to make my containers reachable from other machines on my LAN](#i-want-to-make-my-containers-reachable-from-other-machines-on-my-lan)
  - [DNS SRV/MX record lookups fail when using VirtualBox](#dns-srvmx-record-lookups-fail-when-using-virtualbox)
  - [How can I run X11 apps in Docker and have them display on my Mac?](#how-can-i-run-x11-apps-in-docker-and-have-them-display-on-my-mac)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Dinghy FAQ

Solutions to many common problems can be found here.

## The `docker` client gives an SSL error or times out

The most common cause is the `DOCKER_*` environment variables not being set
correctly. Check the output of `dinghy status` from the same terminal window. If
it displays a message such as

    To connect the Docker client to the Docker daemon, please set:

    export DOCKER_HOST=tcp://192.168.99.101:2376

this means your envionment variables aren't correctly set. Of course if `dinghy
status` reports that the VM is stopped, you should run `dinghy up` as
well.

## The `docker` client reports errors like `x509: certificate is valid for 192.168.x.y, not 192.168.x.z`

Sometimes the IP address of the docker-machine VM changes on restart, which in
turn causes the certificates for the VM to not work. Current versions of
docker-machine don't handle this for you, and neither does Dinghy, so to fix
this you need to regenerate the certificates with:

    $ docker-machine regenerate-certs dinghy

Replace `dinghy` with the VM machine name if you aren't using the default name.

## I'm running into file permissions issues on the NFS mounted volumes

Unfortunately, there isn't yet a one-size-fits-all solution for sharing folders
from the host OS X machine into the Linux VM and then into the docker
containers, and permissions issues are sometimes a problem. This isn't an issue
unique to Dinghy, and is a common point of discussion in projects like Docker
Machine as well.

Because Dinghy is geared toward development, it optimizes for sharing source
code directories between the containers and host, and then uses NFS for
performance. This works really well for editing code in OS X and seeing the
changes immediately in your running containers, but can cause problems with
mounting volumes from the host in some containers that expect files to be owned
by certain users, since the files can't be successfully chown'd to the user
running in the container.

In practice, this means that it's usually best to run containers such as
postgres using a normal docker volume, rather than a host-shared volume. This is
the default, so normally nothing needs to be done, but you may run into chown
errors or other file permissions issues if you try to mount a host volume into
such containers.

For more background on the decisions made here, see the discussion in issues
such as https://github.com/codekitchen/dinghy/issues/31 and
https://github.com/codekitchen/dinghy/issues/15

In the future this may be solvable using user namespacing, which was introduced
in a very limited form in docker 1.10. It would also be possible in theory to
modify the NFS server process to do things such as ignore chown commands, but
this isn't currently planned.

## I can't connect to an app running in docker from another VM (commonly to test in IE)

If you are running the Windows VM in VirtualBox, you can configure it to use the
host DNS resolver:

    VBoxManage modifyvm "IE11 - Win10" --natdnshostresolver1 on

Replace `"IE11 - Win10"` with the name of your VM. This will allow the VM to
resolve and connect directly to your `http://*.docker` services running in
Dinghy.

## I want to make my containers reachable from other machines on my LAN

Your Docker VM is configured to use a host-only network, so it's not accessible
outside your computer by default. To enable others to reach your VM, you can use
a tool such as [my-proxy](https://github.com/esnunes/my-proxy) to set up a proxy
server. Please be aware of the security implications of exposing your containers
in this way, and don't do it on an untrusted network.

Alternatively, you can use [stone](http://www.gcd.org/sengoku/stone/) (can be installed with `brew`), which will make a proxy to all exposed Docker ports
on Dinghy's IP from localhost:

```bash
stone `docker ps -q | grep -v $(docker ps -q --filter='name=dinghy_http_proxy') | xargs -L 1 docker port | grep -o "[0-9]\+$" | tr '\n' ' ' | sed -e "s/\([0-9]\{1,\}\)/$(dinghy ip):\1 \1 --/g"`
```

The command can be defined as a bash function in **~/.bash_profile** for quick usage:

```bash
function dinghy-expose {
    binds=`docker ps -q | grep -v $(docker ps -q --filter='name=dinghy_http_proxy') | xargs -L 1 docker port | grep -o "[0-9]\+$" | tr '\n' ' ' | sed -e "s/\([0-9]\{1,\}\)/$(dinghy ip):\1 \1 --/g"`
    eval stone $binds
}
```

## DNS SRV/MX record lookups fail when using VirtualBox

This is an issue with VirtualBox DNS serving, see https://github.com/codekitchen/dinghy/issues/172

There is a workaround there, turning on `natdnsproxy1` for the VM, but
unfortunately this breaks resolving of `*.docker` domains from within the VM. So
there is no known VirtualBox configuration that fixes all problems.

## How can I run X11 apps in Docker and have them display on my Mac?

1. If you haven't already, install the latest version of [XQuartz](https://www.xquartz.org). Reboot your Mac. Logging out and back in is not sufficient.
1. Launch XQuartz, open Preferences->Security, and enable "Allow connections from network clients". This only needs to be done once.
1. On each launch of XQuartz, you will need to enable connections from the Dinghy VM IP address with `xhost + $(dinghy ip)`
1. Then you can just launch a Docker container setting `-e DISPLAY=$(dinghy ip --host):0` and any X11 applications run in the container should display on the host.

For instance, here is how to run firefox:

```bash
$ open -a XQuartz
$ xhost + $(dinghy ip)
$ docker run --rm -e DISPLAY=$(dinghy ip --host):0 jess/firefox
``` 

Please make sure you understand the risks of allowing X11 applications to run. Do not run untrusted X11 containers.