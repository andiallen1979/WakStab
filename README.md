# WakStab Gentoo Overlay & Binhost Configs

Personal Gentoo Linux overlay, kernel/system configuration packages, and Portage helper scripts for the **WakStab** binhost.

## Overlay Packages

* **`app-misc/wakstab-meta`**: Meta-package pulling in the WakStab environment (`USE="+conf +kconf +scripts menu"`).
* **`app-misc/wakstab-menu`**: Interactive `kconfiglib` (`menuconfig`) TUI for managing Portage configuration across installed packages and global settings.
* **`app-portage/wakstab-scripts`**: CLI helper utilities for Portage configuration, NBD disk imaging, package cleanup, and overlay maintenance.
* **`sys-config/wakstab-configs`**: Host Portage configuration files (`/etc/portage/make.conf`, `package.*`, `repos.conf`, `patches/`).
* **`sys-kernel/wakstab-kernel-config`**: Custom kernel configuration presets.
* **`sys-boot/wakstab-bootcfg`**: Declarative bootloader and Secure Boot switcher (`USE="grub|systemd-boot|refind secureboot"`).

## Quick Setup

```bash
eselect repository enable WakStab
emaint sync -r WakStab
emerge -av app-misc/wakstab-meta
```

## `wakstab-menu` TUI

Launch `sudo wakstab-menu` to manage six Portage areas in a single `menuconfig` interface:

1. **USE Flags (`package.use`)**: Category/package toggles saved as single unversioned lines in `/etc/portage/package.use/<cat>/<pkg>`.
2. **Accept Keywords (`package.accept_keywords`)**: Toggle `~amd64` and `**` per package.
3. **Package Masking (`package.mask`)**: Choose `Unmasked`, `cat/pkg` (all), `=cat/pkg-ver` (exact), or `>=cat/pkg-ver` (forward).
4. **Package Environments (`package.env`)**: Assign `/etc/portage/env/*.conf` profiles per package.
5. **Environment Profiles (`/etc/portage/env`)**: Edit existing `.conf` variables, create new profiles, or toggle presets.
6. **Global `make.conf` (`USE` & `FEATURES`)**: Toggle global `USE` flags and `FEATURES` (`getbinpkg`, `buildpkg`, `ccache`, etc.).

## Portage CLI Helpers (`wakstab-scripts`)

All package helpers enforce single-entry per-package files (`/etc/portage/<type>/<cat>/<pkg>`), support `-t` (`TMP_` prefix), and resolve `::repo` atoms when using `-f` (`>=cat/pkg-ver::repo`) or `-e` (`=cat/pkg-ver::repo`):

* **`setpkguse`**:
  * `setpkguse <cat/pkg>` (or `-i`): Interactive `select`/`case` flag toggle menu.
  * `setpkguse -v <cat/pkg>`: View live installed and pending USE flag states.
  * `setpkguse [-t] [-f] <cat/pkg> <flags...>`: Set USE flags directly.
* **`setpkgkw`**:
  * `setpkgkw [-u|-s|-m] [-f|-e] [-t] <cat/pkg> [keywords...]`: Set `~amd64` (`-u`), `amd64` (`-s`), or `**` (`-m`) keywords.
* **`setpkgmask`**:
  * `setpkgmask [-f|-e] [-t] <cat/pkg>`: Mask all versions, exact version (`-e`), or forward (`-f`).
* **`setpkgenv`**:
  * `setpkgenv <cat/pkg>` (or `-i`): Interactive `select`/`case` toggle menu for `/etc/portage/env/*.conf` profiles.
  * `setpkgenv [-f|-e] [-t] <cat/pkg> <profile...>`: Assign `.conf` profiles directly (auto-appends `.conf` if omitted).
* **Overlay & Maintenance Tools**: `cleanpkg`, `mknbdimg`, `wakstab-bump`, `wakstab-repo-prep`, `wakstab-sync-configs`, `wakstab-push`.
