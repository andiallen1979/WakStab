# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Classic colorful XDG icon theme for QParted"
HOMEPAGE="https://codeberg.org"
S="${WORKDIR}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"

src_unpack() {
	unpack "${FILESDIR}/${PN}-0.1.0.tar.xz"
}

src_install() {
	insinto /usr/share/icons/qparted-color
	doins -r index.theme scalable
}
