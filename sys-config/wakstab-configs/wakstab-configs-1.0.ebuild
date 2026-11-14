# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Fleet-wide Portage configuration tree for WakStab"
HOMEPAGE="https://codeberg.org/andiallen1979/WakStab"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	app-portage/wakstab-scripts
	sys-kernel/wakstab-kernel-config
"

src_install() {
	local dir
	for dir in package.use package.mask package.env package.accept_keywords env repos.conf patches savedconfig; do
	if [[ -d "${FILESDIR}/${dir}" ]]; then
		insinto "/etc/portage/${dir}"
		doins -r "${FILESDIR}/${dir}/."
	fi
	done

	insinto /etc/portage/env
	newins "${FILESDIR}/env/ramhog-0.conf" totalpig.conf

	local pkg
	for pkg in app-emulation/gxemul dev-debug/gdbgui dev-python/pypresence media-video/devedeng; do
	insinto "/etc/portage/package.accept_keywords/${pkg%/*}"
	doins "${FILESDIR}/package.use/${pkg}"
	done

	insinto /etc/portage/patches/sys-kernel/neptune-kernel
	doins "${FILESDIR}/patches/sys-kernel/gentoo-kernel/ra24-fix.patch"
}

pkg_postinst() {
	elog "WakStab Portage configuration tree has been installed to /etc/portage."
	elog "Run 'dispatch-conf' or 'etc-update' to merge any updated config files."
}
