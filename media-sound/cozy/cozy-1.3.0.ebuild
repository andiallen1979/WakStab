# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit gnome2-utils meson python-single-r1 xdg

DESCRIPTION="Modern audio book player for Linux built with GTK4 and Libadwaita"
HOMEPAGE="https://cozy.sh https://github.com/geigi/cozy"
SRC_URI="https://github.com/geigi/cozy/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEPS}
	dev-libs/glib:2
	gui-libs/gtk:4[introspection]
	>=gui-libs/libadwaita-1.5.0:1[introspection]
	media-libs/gstreamer:1.0[introspection]
	media-libs/gst-plugins-base:1.0[introspection]
"

RDEPEND="
	${DEPEND}
	media-libs/gst-plugins-good:1.0
	media-libs/gst-plugins-bad:1.0
	media-libs/gst-plugins-ugly:1.0
	media-plugins/gst-plugins-libav:1.0
	$(python_gen_cond_dep '
		dev-python/apsw[${PYTHON_USEDEP}]
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/distro[${PYTHON_USEDEP}]
		dev-python/gst-python:1.0[${PYTHON_USEDEP}]
		media-libs/mutagen[${PYTHON_USEDEP}]
		>=dev-python/peewee-3.9.6[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		dev-python/pytz[${PYTHON_USEDEP}]
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
