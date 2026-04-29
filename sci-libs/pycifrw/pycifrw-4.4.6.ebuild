# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Reading and writing CIF (Crystallographic Information Format) files"
HOMEPAGE="https://pypi.org/project/PyCifRW/ https://github.com/jamesrhester/pycifrw/"
SRC_URI="https://github.com/jamesrhester/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="ASRP"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/ply[${PYTHON_USEDEP}]
"

# 2026-04-29: TestPyCIFRW.py / TestDrel.py live at the source root and use
# relative "tests/" data paths; unittest discover instead picks up src/ and
# fails. Running the test scripts directly would also need RDEPENDs added as
# test deps. Skip until upstream restructures.
RESTRICT="test"
