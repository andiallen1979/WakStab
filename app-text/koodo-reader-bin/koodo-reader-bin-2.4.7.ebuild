# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker xdg

DESCRIPTION="Modern ebook manager and reader with sync and backup capacities"
HOMEPAGE="https://www.koodoreader.com https://github.com/koodo-reader/koodo-reader"
SRC_URI="
	amd64? ( https://github.com/koodo-reader/koodo-reader/releases/download/v${PV}/Koodo-Reader-${PV}-amd64.deb )
	arm64? ( https://github.com/koodo-reader/koodo-reader/releases/download/v${PV}/Koodo-Reader-${PV}-arm64.deb )
"

S="${WORKDIR}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxkbcommon
	x11-libs/pango
"

QA_PREBUILT="*"

src_install() {
	cp -a usr opt "${ED}" || die
	dosym ../../opt/Koodo\ Reader/koodo-reader /usr/bin/koodo-reader
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
