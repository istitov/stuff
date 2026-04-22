# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Format a simple list into aligned columns"
HOMEPAGE="
	https://github.com/rocky/columnize
	https://pypi.org/project/columnize/
"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
