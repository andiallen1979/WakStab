# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Meta-package for wakstab system configurations, kernel config, and scripts"
HOMEPAGE="https://codeberg.org/andiallen1979/WakStab"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64"
IUSE="+conf +kconf +scripts"

RDEPEND="
	conf? ( sys-config/wakstab-configs )
	kconf? ( sys-kernel/wakstab-kernel-config )
	scripts? ( app-portage/wakstab-scripts )
"
