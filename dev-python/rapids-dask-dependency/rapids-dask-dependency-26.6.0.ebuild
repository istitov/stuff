# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

# GitHub zero-pads the calendar version in the tag (26.06.00); PyPI
# normalises it to 26.6.0, which is our ${PV}.
MY_PV="26.06.00"

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

# Upstream pins dask/distributed to an exact RAPIDS-tested snapshot
# (>=2026.1.1,<2026.1.2). That cap is NOT functionally load-bearing for
# this release: the package's whole runtime job is to import-hook dask
# and distributed and apply version-specific monkeypatches, but in
# 26.6.0 both patch entrypoints are no-ops
# (patches/{dask,distributed}/__init__.py call
# make_monkey_patch_loader(..., lambda _: None)), so nothing is keyed to
# the exact dask version. We relax the upper cap (see src_prepare) so the
# shim coexists with our dev-python/dask-2026.3.0 rather than forcing a
# downgrade. verified 2026-06-10
RDEPEND="
	>=dev-python/dask-2026.1.1[${PYTHON_USEDEP}]
	>=dev-python/distributed-2026.1.1[${PYTHON_USEDEP}]
"

python_prepare_all() {
	# The release tag carries a dev-alpha version (26.06.00a0); RAPIDS CI
	# strips the suffix when cutting the final wheel. Restore the released
	# version so the built dist reports 26.6.0, not 26.6.0a0.
	sed -i -e 's/^version = "26\.06\.00a0"/version = "26.06.00"/' \
		pyproject.toml || die

	# Relax the brittle exact dask/distributed cap (see RDEPEND note).
	sed -i \
		-e 's/"dask>=2026.1.1,<2026.1.2"/"dask>=2026.1.1"/' \
		-e 's/"distributed>=2026.1.1,<2026.1.2"/"distributed>=2026.1.1"/' \
		pyproject.toml || die

	distutils-r1_python_prepare_all
}
