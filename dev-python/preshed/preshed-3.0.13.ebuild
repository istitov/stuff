# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Cython hash table that trusts the keys are pre-hashed"
HOMEPAGE="
	https://github.com/explosion/preshed
	https://pypi.org/project/preshed/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# GitHub tags lag PyPI; spaCy/Thinc require Preshed <3.1.
RDEPEND="
	${PYTHON_DEPS}
	>=dev-python/cymem-2.0.2[${PYTHON_USEDEP}]
	<dev-python/cymem-2.1[${PYTHON_USEDEP}]
	>=dev-python/murmurhash-0.28.0[${PYTHON_USEDEP}]
	<dev-python/murmurhash-1.1[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-python/cython[${PYTHON_USEDEP}]
"
