# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Modern high-performance serialization utilities for Python"
HOMEPAGE="
	https://github.com/explosion/srsly
	https://pypi.org/project/srsly/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Pinned to 2.5.x: spacy and thinc cap srsly<3.0.0. PyPI sdist is
# the canonical source — github tags only go up to v2.4.8, which fails
# to build with current Cython 3.x due to PyInt_Check / Python-2-isms
# in srsly/msgpack/_packer.pyx; the fix lives only in the PyPI 2.5.x
# release. (verified 2026-05-09)
RDEPEND="
	${PYTHON_DEPS}
	dev-python/catalogue[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/cython[${PYTHON_USEDEP}]
"
