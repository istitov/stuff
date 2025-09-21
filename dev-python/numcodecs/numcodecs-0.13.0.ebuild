# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 pypi

DESCRIPTION="A Python package providing buffer compression and transformation codecs for use in data storage and communication applications"
HOMEPAGE="https://github.com/zarr-developers/numcodecs"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
