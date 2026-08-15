# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

MY_PN="pymatgen_io_validation"
DESCRIPTION="Schema-validation helpers for pymatgen IO classes"
HOMEPAGE="
	https://github.com/materialsproject/pymatgen-io-validation/
	https://pypi.org/project/pymatgen-io-validation/
"
SRC_URI="$(pypi_sdist_url --no-normalize "${MY_PN}" "${PV}")"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/pymatgen-2026.4.16[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		>=dev-python/pydantic-2.0.1[${PYTHON_USEDEP}]
		>=dev-python/pydantic-settings-2.0.0[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/setuptools-65[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	# The sdist has no VCS metadata and therefore publishes version 0.0.0.
	# Pin the release version and avoid invoking versioningit in the gitless
	# build tree.
	sed -i \
		-e 's/"versioningit >= 1,< 4", //' \
		-e 's/dynamic = \["version"\]/version = "'"${PV}"'"/' \
		pyproject.toml || die
	distutils-r1_src_prepare
}
