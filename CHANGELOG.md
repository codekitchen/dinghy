# Change Log
All notable changes to this project will be documented in this file.

## Unreleased

### Changed
- Update to dinghy-http-proxy 2.6 branch. Uses alpine branch of nginx-proxy.
- Fix `fsevents_to_vm` config when overriding DINGHY_HOST_MOUNT_DIR.
- Add DINGHY_CERT_PATH env var for when overriding DINGHY_HOST_MOUNT_DIR.

## 4.6.5 - 2018-07-05

### Changed
- Handle errors closing the SSH connection in `fsevents_to_vm`.

## 4.6.4 - 2018-06-05

### Added
- Coerce Thor to support `-h` and `--help` flags for individual commands.
- Support for passing through docker-machine's `--engine-opt` flag.
- Support for nanosecond timestamps in `fsevents_to_vm` to match High Sierra's nanosecond timestamps. Requires a dev branch of `unfs3` as well, which the Homebrew installer now points to.

## 4.6.3 - 2018-01-26

### Added
- `nfs_port` preference to define a different NFS port to use on the VM net interface.

### Changed
- Remove random port selection for unfsd and use hard-coded port number.
- Extended error handling for `fsevents_to_vm` SSH errors.

## 4.6.1 - 2017-12-08

### Changed
- Fix fish shell support for setting env vars.
- Fix `proxy_disabled` logic.

## 4.6.0 - 2017-11-17

### Added
- Display Fish syntax for setting env variables.
- `dinghy ip --host` option to output host IP.

### Changed
- Use submodules for fsevents_to_vm rather than a `gem install`.

## 4.5.0 - 2017-02-06

### Added
- Custom nginx proxy config support.

### Changed
- Track minor version for HTTP proxy, rather than patchlevel version. Now small changes can be made to the proxy without a new version of Dinghy.
- Fix `dinghy create` for Docker 1.13 compatibility.
- Proxy: leave docker networks when there are no active containers in the network, to make destroying the network easier.

## 4.4.3 - 2016-12-15

### Changed
- More improved/consistent error handling.
- Work around MacOS DNS resolution failing briefly after configuring the `.docker` domain.
- Stop the DNS/HTTP proxy more gracefully.

## 4.4.2 - 2016-10-24

### Added
- Add `hostmachine.docker` DNS address pointing to the host OS X machine for use in containers.

### Changed
- Show DNS and Proxy status separately.
- Slightly improved error handling.
- Proxy updates.

## 4.4.1 - 2016-06-28

### Changed
- Fix NFS daemon `logpath` error.

### Added
- Added default vhost splash screen to the HTTP proxy.

## 4.4.0 - 2016-05-20

### Changed
- Updated jwilder/nginx-proxy base image.
- Use the new dinghy-http-proxy that contains the DNS resolver.
- Set VirtualBox DNS options on each start, rather than once at VM create.
- Support [`HTTPS_METHOD`](https://github.com/jwilder/nginx-proxy/pull/298) env var for the proxy.
- SSH key fix in fsevents_to_vm.
- Wildcard the auto-generated docker-compose proxy hostnames.

### Removed
- Remove the host dnsmasq proxy, as it now runs in Docker.

## 4.3.2 - 2016-03-29

### Added
- Basic HTTPS support in the proxy, using manually-installed certs.

### Changed
- Don't restart on 'up' if already started.
- Better handling of commands before the VM is created.
- Decrease the logic in the sudo'd NFS process to avoid issues with various sudoers configurations.

## 4.3.1 - 2016-03-03

### Changed
- Fix FS Events forwarding to xhyve VMs.

## 4.3.0 - 2016-03-03

### Added
- Allow specifying the docker-machine machine name in the preferences file. This is primarily to enable using Dinghy with Kitematic.
- Added xhyve support via https://github.com/zchee/docker-machine-driver-xhyve
- Added parallels support via https://github.com/Parallels/docker-machine-parallels
- Allow configuring the resolved domain to something other than `.docker`.

### Changed
- Start the VM on `upgrade` when necessary.
- Remove the `dinghy nfs` command from the public CLI, it is only for internal use.
- Upgrade the HTTP proxy to deal with docker's new networking layer and docker-compose v2 configs.
- Fix `DINGHY_HOST_MOUNT_DIR` option.

## 4.2.0 - 2016-01-22

### Changed
- Fix for specifying an alternate mount dir.
- Shell out to `docker-machine ssh` now that it has much improved, and remove our custom ssh code.
- require Machine version 0.5.5

### Removed
- `dinghy ssh-config` command.

## 4.1.0 - 2016-01-04

### Changed
- Fix `dinghy` binary name in the help text.
- Switch from using launchd to managing our own daemons.
- Add better error handling and logging for the fsev/dns/nfs daemons.
- Allow installing docker/docker-machine from any source by removing the brew dependencies.
- Remove the "brute force search" flag from unfsd.
- Move DNS listener to 127.0.0.1 to work around OS X not even attempting to use it when offline.

## 4.0.8 - 2015-11-23

### Changed
- docker-machine 0.5.1 compatibility.

## 4.0.7 - 2015-11-08

### Changed
- Revert AuthOptions commit due to docker-machine inconsistency.

## 4.0.6 - 2015-11-08

### Changed
- Fix compatibility with docker-machine 0.5.0

## 4.0.5 - 2015-10-29

### Added
- `start` alias for `dinghy up`.
- `stop` and `down` aliases for `dinghy halt`.

### Changed
- Always install the `fsevents_to_vm` binary to a set path, to avoid differences between Yosemite and El Capitan installs.

## 4.0.4 - 2015-10-12

### Changed
- Fix an issue with fsevents_to_vm after upgrading to El Capitan with Dinghy already installed.

## 4.0.3 - 2015-09-29

### Changed
- Increase SSH error logging.

## 4.0.2 - 2015-09-16

### Changed
- Fix fsevents_to_vm path on OS X 10.11.

## 4.0.1 - 2015-09-04

### Added
- `dinghy` command shim to unset GEM_HOME env vars, to fix issues with rvm/chruby.

## 4.0.0 - 2015-09-03

### Changed
- Major change: removed `vagrant` support, replaced with `docker-machine`.
- Gracefully handle `dinghy up` when the VM is already running.

### Added
- Split VM creation into a separate `dinghy create` command.

## 3.1.2 - 2015-08-17

### Changed
- Create ~/.dinghy directory on install if it does not exist.

## 3.1.1 - 2015-08-13

### Changed
- Docker version 1.8.1

## 3.1.0 - 2015-08-12

### Added
- The NFS mount dir can now be configured using environment variables.
- Filesystem events are now forwarded to the VM, using `fsevents_to_vm`.

### Changed
- Removed redundant network interface from the VM Vagrantfile.
- Increase the inotify watcher limit, so fsevents can be used on larger projects.
- Docker version 1.8.0

## 3.0.4 - 2015-08-03

### Changed
- Fix incompatibility with `devel` and the new version of Homebrew.

## 3.0.3 - 2015-07-24

### Changed
- Fix for Homebrew HOME env munging.

## 3.0.2 - 2015-07-15

### Changed
- Docker version 1.7.1

## 3.0.1 - 2015-06-24

### Added
- `dinghy shellinit` command for setting env vars.

### Changed
- Increase the http proxy max body size.
- Docker version 1.7.0

## 3.0.0 - 2015-04-22

### Changed

- Configure user permission squashing on the NFS mount, so that files created on
  mounted volumes will be owned by the host machine user, not by root or a
  non-existent user.

  Upgrade note: you'll need to chown any root-owned files to
  be owned by your user.

- Docker version 1.6.0
- HTTP proxy is now enabled by default. --no-proxy to disable.

## 2.2.2 - 2015-03-24

### Added
- `dinghy ip` command to get the VM IP address.

### Changed
- Revert back to Virtualbox host DNS.

## 2.2.1 - 2015-03-23

### Changed
- Tweak the dnsmasq options to fix a reported issue.
- Fix DHCP on the private interface to avoid IP changes. This should fix
  the issues with NFS breaking until you restart the VM.

## 2.2.0 - 2015-02-11

### Changed
- Docker version 1.5.0

## 2.1.0 - 2015-01-26

### Added
- Vagrant box version check in Vagrantfile.

## 2.0.7 - 2014-12-30

### Changed
- Disable Vagrant ssh key replacement, working around a Vagrant 1.7 issue.

## 2.0.5 - 2014-12-30

### Changed
- Remove the docker SSL port forward from the Vagrantfile, it's on the
  base box now.

## 2.0.4 - 2014-12-30

### Added
- Upgrade command

## 2.0.3 - 2014-12-05

### Added
- Version command `dinghy -v`.
- Don't hang on `dinghy status` if the virtual interface isn't created.
- Remember the `--proxy` option on subsequent VM starts, so you don't
  need to pass it every time.

## 2.0.2 - 2014-12-05

### Changed
- Fix for running the NFS daemon as the correct user under launchd.

## 2.0.0 - 2014-12-04

### Added
- A new DNS daemon resolves \*.docker to the VM's IP.
- Added a restart command (halt + up).
- An optional http proxy service that listens on \*.docker port 80.

### Changed
- New versioning scheme, no longer tying dinghy release version to
  docker/boot2docker version.

## 1.3.0-5 - 2014-11-17

### Changed
- Run the NFS daemon as root, unfortunately necessary to fix various
  permissions issues.
- Rather than an NTP periodic launchd job, add it to root's crontab in
  the VM.

## 1.3.0-4 - 2014-11-07

### Changed
- Fixed DHCP setup race condition in VMWare Fusion.

## 1.3.0-3 - 2014-11-07

### Added
- Fix VM clock skew issues with a periodic NTP sync.
- New CLI commands: status, ssh.
- New CLI options for memory, cpu, vagrant provider.

### Changed
- The CLI now uses Thor.

## 1.3.0-2 - 2014-11-05

### Changed
- Bring up the VM before NFS, so we're sure the private interface has
  been created.

### Removed
- Removed the `init` command, in favor of always using `up`.

## 1.3.0-1 - 2014-11-05

### Added
- Initial release.
