# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake xdg

GPARTED_PV="1.8.0"
DESCRIPTION="Native Qt6 / KDE Plasma partition editor, rescue scanner, and sparse imager"
HOMEPAGE="https://codeberg.org"
SRC_URI="mirror://sourceforge/gparted/gparted-1.8.0.tar.gz"
S="${WORKDIR}/qparted-${PV}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-cpp/glibmm:2
	dev-libs/libsigc++:2
	dev-qt/qtbase:6[gui,widgets]
	kde-frameworks/kconfigwidgets:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kwidgetsaddons:6
	kde-frameworks/kxmlgui:6
	sys-apps/util-linux
	>=sys-block/parted-3.2
"
RDEPEND="${DEPEND}
	sys-auth/polkit
"
BDEPEND="
	dev-lang/python:*
	kde-frameworks/extra-cmake-modules:0
	virtual/pkgconfig
"

src_unpack() {
	default
	mkdir -p "${S}/upstream" || die
	tar -xJf "${FILESDIR}/${P}.tar.xz" -C "${S}" || die
	mv "${WORKDIR}/gparted-1.8.0" "${S}/upstream/gparted" || die
}
