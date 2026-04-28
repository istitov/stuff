# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Reading and writing CIF (Crystallographic Information Format) files"
HOMEPAGE="https://pypi.org/project/PyCifRW/ https://github.com/jamesrhester/pycifrw/"
SRC_URI="https://github.com/jamesrhester/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="ASRP"
SLOT="0"
KEYWORDS="~amd64 ~x86"
