# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Better multiprocessing and multithreading in Python"
HOMEPAGE="
	https://github.com/uqfoundation/multiprocess/
	https://pypi.org/project/multiprocess/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND=">=dev-python/dill-0.4.1[${PYTHON_USEDEP}]"
BDEPEND="test? ( dev-python/test[${PYTHON_USEDEP}] )"

distutils_enable_tests unittest
