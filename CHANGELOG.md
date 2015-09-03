# Change Log
All notable changes to this project will be documented in this file.

## Unreleased

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
