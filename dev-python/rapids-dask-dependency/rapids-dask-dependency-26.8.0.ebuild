# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# Git tags zero-pad the calendar version; PyPI normalizes it to ${PV}.
MY_PV="26.08.00"

DESCRIPTION="Dask and Distributed version pinning shim for RAPIDS"
HOMEPAGE="
	https://github.com/rapidsai/rapids-dask-dependency
	https://pypi.org/project/rapids-dask-dependency/
"
SRC_URI="
	https://github.com/rapidsai/rapids-dask-dependency/archive/refs/tags/v${MY_PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Both patch entrypoints are no-ops, so upstream's exact Dask/Distributed cap
# is not load-bearing; relax it to coexist with packaged Dask. verified 2026-08-06
RDEPEND="
	>=dev-python/dask-2026.7.1[${PYTHON_USEDEP}]
	>=dev-python/distributed-2026.7.1[${PYTHON_USEDEP}]
"

python_prepare_all() {
	# Mirror release CI's removal of the tag's dev-alpha suffix.
	sed -i -e 's/^version = "26\.08\.00a0"/version = "26.08.00"/' \
		pyproject.toml || die

	sed -i \
		-e 's/"dask>=2026.7.1,<2026.7.2"/"dask>=2026.7.1"/' \
		-e 's/"distributed>=2026.7.1,<2026.7.2"/"distributed>=2026.7.1"/' \
		pyproject.toml || die

	distutils-r1_python_prepare_all
}
