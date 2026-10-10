# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Flexible YAML-based configuration system with variable interpolation"
HOMEPAGE="
	https://github.com/hydra-ecosystem/omegaconf
	https://pypi.org/project/omegaconf/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# 2.4 vendors its ANTLR 4.11.1 runtime, so only PyYAML remains external. The
# parser is regenerated at build time with the bundled ANTLR jar, hence the
# JRE. verified 2026-10-10
RDEPEND="
	>=dev-python/pyyaml-5.1.0[${PYTHON_USEDEP}]
"

BDEPEND="
	>=virtual/jre-1.8:*
"
