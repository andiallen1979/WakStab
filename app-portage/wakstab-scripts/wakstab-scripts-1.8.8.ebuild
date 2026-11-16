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

src_unpack() {
	unpack "${WORKDIR}/wakstab-scripts-bundle.tar.xz"
}

src_install() {
	dobin "${WORKDIR}/setpkgkw"
	dobin "${WORKDIR}/setpkgenv"
	dobin "${WORKDIR}/setpkguse"
	dobin "${WORKDIR}/setpkgmask"
	dobin "${WORKDIR}/cleanpkg"
	dobin "${WORKDIR}/mknbdimg"
	dobin "${WORKDIR}/wakstab-repo-prep"
	dobin "${WORKDIR}/wakstab-sync-configs"
	dobin "${WORKDIR}/wakstab-push"
	dobin "${WORKDIR}/wakstab-bump"
	dobin "${WORKDIR}/wakstab-emptytree"
	dobin "${WORKDIR}/wakstab-audit"
}
