# Dinghy FAQ

Solutions to many common problems can be found here.

__TOC__

## The `docker` client gives an SSL error or times out

The most common cause is the `DOCKER_*` environment variables not being set
correctly. Check the output of `dinghy status` from the same terminal window. If
it displays a message such as

    To connect the Docker client to the Docker daemon, please set:

    export DOCKER_HOST=tcp://192.168.99.101:2376

this means your envionment variables aren't correctly set. Of course if `dinghy
status` reports that the VM is stopped, you should run `dinghy up` as
well.

## I can't connect to an app running in docker from another VM (commonly to test in IE)

If you are running the Windows VM in VirtualBox, you can configure it to use the
host DNS resolver:

    VBoxManage modifyvm "IE11 - Win10" --natdnshostresolver1 on

Replace `"IE11 - Win10"` with the name of your VM. This will allow the VM to
resolve and connect directly to your `http://*.docker` services running in
Dinghy.
