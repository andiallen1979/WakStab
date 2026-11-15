# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )

inherit gnome2-utils meson python-single-r1 xdg

DESCRIPTION="Versatile toolbox for viewing Flatpak info and managing user data"
HOMEPAGE="https://github.com"
SRC_URI="https://github.com/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

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
	gnome-base/dconf
	sys-apps/flatpak[introspection]
	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
"

BDEPEND="
	${PYTHON_DEPS}
	dev-libs/appstream
	dev-util/blueprint-compiler
	dev-util/desktop-file-utils
	sys-devel/gettext
"

src_prepare() {
	default
	"${EPYTHON}" - << 'PYEOF' || die
import pathlib, re

pattern = re.compile(r"""["']flatpak-spawn["'],\s*["']--host["'],?\s*""")
for path in pathlib.Path("src").rglob("*.py"):
	orig = path.read_text()
	updated = pattern.sub("", orig)
	if updated != orig:
		path.write_text(updated)
PYEOF
}

src_install() {
	meson_src_install
	fperms +x /usr/bin/warehouse
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
