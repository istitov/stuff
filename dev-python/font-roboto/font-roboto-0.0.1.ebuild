# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Roboto font family exposed through Python entry points"
HOMEPAGE="
	https://github.com/pimoroni/fonts-python
	https://pypi.org/project/font-roboto/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

DOCS=( CHANGELOG.txt README.rst )
