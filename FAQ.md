<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
- [Dinghy FAQ](#dinghy-faq)
  - [The `docker` client gives an SSL error or times out](#the-docker-client-gives-an-ssl-error-or-times-out)
  - [The `docker` client reports errors like `x509: certificate is valid for 192.168.x.y, not 192.168.x.z`](#the-docker-client-reports-errors-like-x509-certificate-is-valid-for-192168xy-not-192168xz)
  - [I can't connect to an app running in docker from another VM (commonly to test in IE)](#i-cant-connect-to-an-app-running-in-docker-from-another-vm-commonly-to-test-in-ie)
  - [I want to make my containers reachable from other machines on my LAN](#i-want-to-make-my-containers-reachable-from-other-machines-on-my-lan)

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
