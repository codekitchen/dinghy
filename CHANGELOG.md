# Change Log
All notable changes to this project will be documented in this file.

## 1.3.0-4 - 2014-10-07

### Changed
- Fixed DHCP setup race condition in VMWare Fusion.

## 1.3.0-3 - 2014-10-07

### Added
- Fix VM clock skew issues with a periodic NTP sync.
- New CLI commands: status, ssh.
- New CLI options for memory, cpu, vagrant provider.

### Changed
- The CLI now uses Thor.

## 1.3.0-2 - 2014-10-05

### Changed
- Bring up the VM before NFS, so we're sure the private interface has
  been created.

### Removed
- Removed the `init` command, in favor of always using `up`.

## 1.3.0-1 - 2014-10-05

### Added
- Initial release.
