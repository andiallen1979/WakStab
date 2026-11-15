# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )

inherit git-r3 gnome2-utils meson python-single-r1 xdg

DESCRIPTION="Flatpak leftover cleaner application"
HOMEPAGE="https://github.com"
EGIT_REPO_URI="https://github.com/giantpinkrobots/flatsweep.git"

LICENSE="MPL-2.0"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEPS}
	dev-libs/glib:2
	gui-libs/gtk:4[introspection]
	gui-libs/libadwaita:1[introspection]
"

RDEPEND="
	${DEPEND}
	sys-apps/flatpak
	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
"

BDEPEND="
	${PYTHON_DEPS}
	dev-libs/appstream
	dev-util/desktop-file-utils
	sys-devel/gettext
"

src_prepare() {
	default
	sed -i 's/if ("io.github.giantpinkrobots.flatsweep" not in flatpakList):/if False:/' src/main.py || die
}

src_install() {
	meson_src_install
	fperms +x /usr/bin/flatsweep
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
