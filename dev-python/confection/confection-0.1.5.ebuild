# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="The sweetest config system for Python"
HOMEPAGE="
	https://github.com/explosion/confection
	https://pypi.org/project/confection/
"
SRC_URI="https://github.com/explosion/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Pinned to 0.1.x (latest sub-1.0 release): dev-python/spacy and
# dev-python/thinc cap confection<1.0.0. PyPI's confection-1.3.3 exists
# but spaCy and thinc don't accept it; that path becomes available only
# if spacy itself bumps the cap upstream.
RDEPEND="
	${PYTHON_DEPS}
	dev-python/pydantic[${PYTHON_USEDEP}]
	dev-python/srsly[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
