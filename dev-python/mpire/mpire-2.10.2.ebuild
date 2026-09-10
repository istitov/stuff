# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="A Python package for easy multiprocessing"
HOMEPAGE="https://github.com/sybrenjansen/mpire"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="dashboard dill numpy"

# Map upstream extras to USE flags; multiprocess implements the dill backend.
RDEPEND="
	>=dev-python/pygments-2.0[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.27[${PYTHON_USEDEP}]
	dashboard? ( dev-python/flask[${PYTHON_USEDEP}] )
	dill? ( >=dev-python/multiprocess-0.70.15[${PYTHON_USEDEP}] )
	numpy? ( dev-python/numpy[${PYTHON_USEDEP}] )
"
