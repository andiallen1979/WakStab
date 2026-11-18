# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..15} )

inherit distutils-r1 pypi

DESCRIPTION="Python library for reading, writing and editing desktop entries"
HOMEPAGE="https://github.com/JakobDev/desktop-entry-lib https://pypi.org/project/desktop-entry-lib/"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
