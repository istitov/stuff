# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Source of XYZ tiles providers"
HOMEPAGE="
	https://github.com/geopandas/xyzservices
	https://pypi.org/project/xyzservices/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

# Ignore test_providers.py: unpackaged mercantile aborts collection, and 10
# of its 11 tests require live tile servers. verified 2026-09-04
EPYTEST_IGNORE=( xyzservices/tests/test_providers.py )
EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	# Pin the version without Git metadata.
	export SETUPTOOLS_SCM_PRETEND_VERSION="${PV}"
	distutils-r1_src_prepare
}
