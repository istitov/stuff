# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN="smart_open"
DESCRIPTION="Utility for streaming large files from S3, HDFS, gzip / bzip2, etc."
HOMEPAGE="
	https://github.com/piskvorky/smart_open
	https://pypi.org/project/smart-open/
"
SRC_URI="https://github.com/piskvorky/${MY_PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/wrapt[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
