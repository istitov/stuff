# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

# 2.1.0 (2021) predates PEP 625, so its sdist keeps the legacy hyphenated
# filename ghp-import-2.1.0.tar.gz rather than the normalized ghp_import-.
PYPI_NO_NORMALIZE=1

inherit distutils-r1 pypi

DESCRIPTION="Copy your docs directly to the gh-pages branch"
HOMEPAGE="
	https://github.com/c-w/ghp-import
	https://pypi.org/project/ghp-import/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND=">=dev-python/python-dateutil-2.8.1[${PYTHON_USEDEP}]"
