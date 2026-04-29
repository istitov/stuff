# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=scikit-build-core
inherit distutils-r1 pypi

DESCRIPTION="library for structural biology"
HOMEPAGE="https://project-gemmi.github.io/"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	virtual/zlib
	dev-python/numpy[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-python/nanobind-2.4[${PYTHON_USEDEP}]
"
