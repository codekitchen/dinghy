# upgrading from vagrant

Dinghy now runs on top of docker-machine. Older versions of Dinghy used to run
on top of Vagrant, using a custom boot2docker machine image.

If you are upgrading from a Vagrant-backed version of Dinghy, for the most part,
you'll just want to follow the normal upgrading steps outlined in [the
README](README.md). Be sure to `dinghy halt` before upgrading.

Your Vagrant VM will not be automatically deleted. Either run `dinghy destroy`
_before_ upgrading dinghy, or run:

     cd `brew --prefix`/var/dinghy/vagrant && vagrant destroy
     rm -rf `brew --prefix`/var/dinghy/vagrant

There is now a separate dinghy command for creating the new vm, run `dinghy help
create` to see the available options.

The `DOCKER_*` connection env vars will change, dinghy will give you the new
values to set.