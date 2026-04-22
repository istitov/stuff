# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="The bidirectional mapping library for Python"
HOMEPAGE="
	https://github.com/jab/bidict
	https://pypi.org/project/bidict/
"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
