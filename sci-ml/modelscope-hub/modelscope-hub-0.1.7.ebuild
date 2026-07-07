# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Model and dataset hub client core for ModelScope"
HOMEPAGE="
	https://github.com/modelscope/modelscope
	https://pypi.org/project/modelscope-hub/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/filelock-3.9[${PYTHON_USEDEP}]
	>=dev-python/requests-2.28[${PYTHON_USEDEP}]
	>=dev-python/tqdm-4.64.0[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.26[${PYTHON_USEDEP}]
"
