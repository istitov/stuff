# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Zero-effort CLI interfaces and config objects from Python types"
HOMEPAGE="
	https://github.com/brentyi/tyro
	https://pypi.org/project/tyro/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# flax/torch are only the dev-nn extra; the core is small and pure-Python.
RDEPEND="
	>=dev-python/docstring-parser-0.16[${PYTHON_USEDEP}]
	>=dev-python/eval-type-backport-0.1.3[${PYTHON_USEDEP}]
	>=dev-python/typeguard-4.0.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.13.0[${PYTHON_USEDEP}]
"
