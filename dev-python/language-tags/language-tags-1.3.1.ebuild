# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Python version of the language-tags Javascript project (BCP 47 / RFC 5646)"
HOMEPAGE="
	https://github.com/OnroerendErfgoed/language-tags
	https://pypi.org/project/language-tags/
"
SRC_URI="https://github.com/OnroerendErfgoed/${PN}/archive/refs/tags/${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
