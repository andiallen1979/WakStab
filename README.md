# WakStab Gentoo Overlay & Binhost Configs

Personal Gentoo Linux overlay, fleet-wide `/etc/portage` configuration tree, modular kernel config fragments, and administrative Portage helper scripts for the **WakStab** binhost.

## Packages Included

| Package | Description |
| :--- | :--- |
| **`app-misc/wakstab-meta`** | Top-level meta-package pulling in the complete WakStab baseline (`USE="+conf +kconf +scripts"`). |
| **`sys-config/wakstab-configs`** | Fleet-wide `/etc/portage` configurations (`make.conf`, `binrepos.conf`, `package.use`, `package.accept_keywords`, `package.mask`, `package.env`, `env`, `repos.conf`, and kernel patches). |
| **`sys-kernel/wakstab-kernel-config`** | Modular kernel configuration snippets installed into `/etc/kernel/config.d` for distribution kernels (`gentoo-kernel`). |
| **`app-portage/wakstab-scripts`** | Portage & overlay management utilities (`setpkgkw`, `setpkgenv`, `setpkguse`, `setpkgmask`, `cleanpkg`, `mknbdimg`, `wakstab-sync-configs`, `wakstab-repo-prep`, `wakstab-bump`, `wakstab-push`). |

## Adding the Overlay

Enable the **WakStab** repository using `eselect-repository`:

```bash
eselect repository add WakStab git https://codeberg.org
emaint sync -r WakStab
```

## Installation

Install the entire WakStab environment via the meta-package:

```bash
emerge -av app-misc/wakstab-meta
```

After installation, merge updated configuration files into `/etc/portage` and `/etc/kernel/config.d`:

```bash
dispatch-conf
```

### Optional USE Flags (`app-misc/wakstab-meta`)

* **`conf`** *(enabled by default)* — Installs `sys-config/wakstab-configs`
* **`kconf`** *(enabled by default)* — Installs `sys-kernel/wakstab-kernel-config`
* **`scripts`** *(enabled by default)* — Installs `app-portage/wakstab-scripts`

## Maintenance Workflow (Binhost Host)

* **Sync live configs, QA-check, and push to Codeberg:**
  ```bash
  wakstab-sync-configs --push
  ```
* **Bump all package versions in the overlay:**
  ```bash
  wakstab-bump <version>
  ```
* **Validate overlay metadata and manifests (`pkgcheck`):**
  ```bash
  wakstab-repo-prep
  ```
