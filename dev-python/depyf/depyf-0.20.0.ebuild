# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Decompile Python functions, from bytecode to source code"
HOMEPAGE="
	https://github.com/thuml/depyf
	https://pypi.org/project/depyf/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/astor[${PYTHON_USEDEP}]
	dev-python/dill[${PYTHON_USEDEP}]
"
