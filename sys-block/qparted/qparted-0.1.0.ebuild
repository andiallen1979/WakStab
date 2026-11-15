# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
inherit cmake python-any-r1 xdg

DESCRIPTION="Native Qt6 / KDE Plasma partition editor, rescue scanner, and sparse imager"
HOMEPAGE="https://codeberg.org/andiallen1979/WakStab"
SRC_URI="https://gitlab.gnome.org/GNOME/gparted/-/archive/484ac562bdaddf0e9c54a1f47b5366f0a72b4dc8/gparted-484ac562bdaddf0e9c54a1f47b5366f0a72b4dc8.tar.bz2"
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
	${PYTHON_DEPS}
	kde-frameworks/extra-cmake-modules:0
	virtual/pkgconfig
"

src_unpack() {
	default
	mkdir -p "${S}/upstream" || die
	tar -xJf "${FILESDIR}/${P}.tar.xz" -C "${S}" || die
	mv "${WORKDIR}/gparted-484ac562bdaddf0e9c54a1f47b5366f0a72b4dc8" "${S}/upstream/gparted" || die
}

src_install() {
	cmake_src_install
	keepdir /usr/share/qparted/images
	fperms 1777 /usr/share/qparted/images
}
