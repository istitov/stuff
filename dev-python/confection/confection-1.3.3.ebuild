# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="The sweetest config system for Python"
HOMEPAGE="
	https://github.com/explosion/confection
	https://pypi.org/project/confection/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Bumped to 1.3.x: dev-python/spacy 3.8.14 wants confection>=1.3.2 and
# dev-python/thinc 8.3.13 wants confection>=1.1.0; the earlier 0.1.5
# pin was based on a misread of thinc 9.x's constraints (which spacy
# 3.8.14 doesn't accept). This is the version that actually solves.
RDEPEND="
	${PYTHON_DEPS}
	dev-python/pydantic[${PYTHON_USEDEP}]
	dev-python/srsly[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
