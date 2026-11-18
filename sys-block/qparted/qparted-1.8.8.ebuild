# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )
inherit cmake git-r3 python-any-r1 xdg

DESCRIPTION="Native Qt6 / KDE Plasma partition editor, rescue scanner, and sparse imager"
HOMEPAGE="https://fragtoo.com"
EGIT_REPO_URI="https://gitlab.gnome.org/GNOME/gparted.git"
EGIT_COMMIT="484ac562bdaddf0e9c54a1f47b5366f0a72b4dc8"
EGIT_CHECKOUT_DIR="${WORKDIR}/gparted-upstream"
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
	git-r3_src_unpack
	mkdir -p "${S}/upstream" || die
	tar -xJf "${FILESDIR}/qparted-src-0.1.0.tar.xz" -C "${S}" || die
	tar -xJf "${FILESDIR}/qparted-meta-0.1.0.tar.xz" -C "${S}" || die
	mv "${EGIT_CHECKOUT_DIR}" "${S}/upstream/gparted" || die
}

src_install() {
	cmake_src_install
	keepdir /usr/share/qparted/images
	fperms 1777 /usr/share/qparted/images
}
