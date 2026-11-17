# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="WakStab host kernel configuration snippets for /etc/kernel/config.d"
HOMEPAGE="https://codeberg.org"
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"

src_install() { insinto /etc/kernel/config.d; doins "${FILESDIR}"/*.config; }
