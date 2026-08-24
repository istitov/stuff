# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Generate fake browser user-agent strings"
HOMEPAGE="
	https://github.com/fake-useragent/fake-useragent
	https://pypi.org/project/fake-useragent/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND=">=dev-python/setuptools-77.0[${PYTHON_USEDEP}]"

# Upstream does not declare the test runner in project metadata.
RESTRICT="test"
