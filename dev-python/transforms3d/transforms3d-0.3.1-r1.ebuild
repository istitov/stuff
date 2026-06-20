# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Code to convert between various geometric transformations"
HOMEPAGE="https://github.com/matthew-brett/transforms3d"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

RDEPEND="
	>=dev-python/numpy-1.5.1[${PYTHON_USEDEP}]
"

src_prepare() {
	# versioneer.py uses two APIs removed in Python 3.12: SafeConfigParser (a
	# deprecated alias of ConfigParser since 3.2) and ConfigParser.readfp
	# (renamed to read_file). Restore the build on 3.12+.
	sed -i -e 's/SafeConfigParser/ConfigParser/g' \
		-e 's/\.readfp(/.read_file(/g' versioneer.py || die
	distutils-r1_src_prepare
}
