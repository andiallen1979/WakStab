# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="WakStab Helper scripts"
HOMEPAGE="https://codeberg.org/andiallen1979/WakStab"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	app-shells/bash
	sys-apps/portage
"

src_install() {
	dobin "${FILESDIR}/setpkgkw"
	dobin "${FILESDIR}/setpkgenv"
	dobin "${FILESDIR}/setpkguse"
	dobin "${FILESDIR}/setpkgmask"
	dobin "${FILESDIR}/cleanpkg"
	dobin "${FILESDIR}/mknbdimg"
	dobin "${FILESDIR}/wakstab-repo-prep"
	dobin "${FILESDIR}/wakstab-sync-configs"
	dobin "${FILESDIR}/wakstab-push"
	dobin "${FILESDIR}/wakstab-bump"
	dobin "${FILESDIR}/wakstab-emptytree"
	dobin "${FILESDIR}/wakstab-audit"
}
