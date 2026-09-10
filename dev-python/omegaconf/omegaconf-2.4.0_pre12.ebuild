# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

# Use the 2.4 prerelease for the modern torch/HF stack: 2.3's ANTLR 4.9 parser
# is incompatible with the tree's 4.11 runtime. 2.4 vendors ANTLR 4.11.1, so
# only PyYAML remains external. verified 2026-07-04
MY_PV="2.4.0.dev12"
DESCRIPTION="Flexible YAML-based configuration system with variable interpolation"
HOMEPAGE="
	https://github.com/omry/omegaconf
	https://pypi.org/project/omegaconf/
"
SRC_URI="$(pypi_sdist_url "${PN}" "${MY_PV}")"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=dev-python/pyyaml-5.1.0[${PYTHON_USEDEP}]
"

BDEPEND="
	>=virtual/jre-1.8:*
"
