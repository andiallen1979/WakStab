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

## Using the WakStab Binhost

If you install `sys-config/wakstab-configs`, your `/etc/portage/binrepos.conf/` directory is already populated. To configure a client machine manually or verify your setup:

1. **Configure `/etc/portage/binrepos.conf/wakstab.conf`:**
   ```ini
   [wakstab]
   priority = 9999
   sync-uri = http://<wakstab-binhost-address>/packages
   ```

2. **Enable binary package fetching in `/etc/portage/make.conf`:**
   ```bash
   FEATURES="\${FEATURES} getbinpkg binpkg-request-signature"
   ```
   *(If your binhost does not sign packages with GPG, omit `binpkg-request-signature` or set `FEATURES="${FEATURES} getbinpkg"`.)*

3. **Initialize binary package GPG trust (if using signed packages):**
   ```bash
   getuto
   ```

4. **Install or upgrade using prebuilt binaries:**
   ```bash
   emerge -avuDN --getbinpkg @world
   ```
   *(Pass `--getbinpkgonly` / `-G` if you want Portage to fail rather than fall back to local compilation when a binary is unavailable.)*

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
