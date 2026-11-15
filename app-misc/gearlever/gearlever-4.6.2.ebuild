# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )

inherit gnome2-utils meson python-single-r1 xdg

DESCRIPTION="Manage AppImages with ease"
HOMEPAGE="https://mijorus.it https://github.com/mijorus/gearlever"
SRC_URI="https://github.com/mijorus/gearlever/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEPS}
	dev-libs/glib:2
	gui-libs/gtk:4[introspection]
	gui-libs/libadwaita:1[introspection]
"

RDEPEND="
	${DEPEND}
	app-arch/7zip
	gnome-base/dconf
	sys-devel/binutils
	sys-fs/fuse:0
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/desktop-entry-lib[${PYTHON_USEDEP}]
		dev-python/ftputil[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
	')
"

BDEPEND="
	${PYTHON_DEPS}
	dev-libs/appstream
	dev-util/blueprint-compiler
	dev-util/desktop-file-utils
	sys-devel/gettext
"

src_install() {
	meson_src_install
	python_fix_shebang "${ED}/usr/bin"
	python_optimize
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
