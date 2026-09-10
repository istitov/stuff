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

# Confection 1.3 satisfies spaCy 3.8 and Thinc 8.3; the old 0.1.5 pin came
# from incompatible Thinc 9 metadata.
RDEPEND="
	${PYTHON_DEPS}
	dev-python/pydantic[${PYTHON_USEDEP}]
	dev-python/srsly[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
