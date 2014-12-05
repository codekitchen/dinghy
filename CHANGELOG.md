# Change Log
All notable changes to this project will be documented in this file.

## Unreleased

### Added
- Version command `dinghy -v`.
- Don't hang on `dinghy status` if the virtual interface isn't created.

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
