# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

# upstream sdist filename uses dash, eclass would normalise to underscore
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Stop-sequence support for Hugging Face Transformers generation"
HOMEPAGE="
	https://github.com/hyunwoongko/stop-sequencer
	https://pypi.org/project/stop-sequencer/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=sci-ml/transformers-4.3.0[${PYTHON_USEDEP}]
"

src_prepare() {
	# upstream find_packages() picks up tests/ which lands as a stray
	# top-level dir in site-packages
	sed -i 's|find_packages()|find_packages(exclude=["tests*"])|' setup.py || die
	distutils-r1_src_prepare
}
