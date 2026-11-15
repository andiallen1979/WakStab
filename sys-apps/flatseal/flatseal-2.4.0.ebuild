# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2-utils meson xdg

DESCRIPTION="Graphical utility to review and modify Flatpak application permissions"
HOMEPAGE="https://github.com/tchx84/Flatseal"
SRC_URI="https://github.com/tchx84/Flatseal/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Flatseal-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	dev-libs/glib:2
	dev-libs/gjs
	gui-libs/gtk:4[introspection]
	>=gui-libs/libadwaita-1.8.0:1[introspection]
"

RDEPEND="
	${DEPEND}
	sys-apps/flatpak[introspection]
	x11-libs/libnotify[introspection]
"

BDEPEND="
	dev-libs/appstream
	dev-util/desktop-file-utils
	sys-devel/gettext
"

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
