# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="WakStab Helper scripts"
HOMEPAGE="https://codeberg.org"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="app-shells/bash sys-apps/portage"

src_unpack() { unpack "${FILESDIR}/wakstab-scripts-bundle.tar.xz"; }

src_install() {
	dobin "${WORKDIR}"/{setpkgkw,setpkgenv,setpkguse,setpkgmask,cleanpkg,mknbdimg,wakstab-repo-prep,wakstab-sync-configs,wakstab-push,wakstab-bump,wakstab-emptytree,wakstab-audit}
}
