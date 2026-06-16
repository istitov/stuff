# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Modules to convert numbers to words in many languages"
HOMEPAGE="
	https://github.com/savoirfairelinux/num2words
	https://pypi.org/project/num2words/
"
SRC_URI="https://github.com/savoirfairelinux/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/docopt[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
