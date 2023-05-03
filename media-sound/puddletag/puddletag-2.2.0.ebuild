# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9,10,11} )

inherit distutils-r1 xdg-utils

DESCRIPTION="Audio tag editor"
HOMEPAGE="http://docs.puddletag.net/"
SRC_URI="https://github.com/puddletag/${PN}/releases/download/${PV}/${P}.tar.gz"

LICENSE="GPL-2 GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="acoustid cover"

DEPEND=""
RDEPEND=">=dev-python/PyQt5-5.9.2[${PYTHON_USEDEP},svg]
	>=dev-python/pyparsing-1.5.1[${PYTHON_USEDEP}]
	>=media-libs/mutagen-1.21[${PYTHON_USEDEP}]
	>=dev-python/configobj-4.7.2-r1[${PYTHON_USEDEP}]
	acoustid? ( >=media-libs/chromaprint-0.6 )
	cover? ( dev-python/pillow[${PYTHON_USEDEP}] )
	>=dev-python/sip-6.6.2[${PYTHON_USEDEP}]
	>=dev-python/lxml-3.0.1[${PYTHON_USEDEP}]"

DOCS=(changelog NEWS THANKS TODO)
