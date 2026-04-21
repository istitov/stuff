# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

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
	dev-python/pymatgen[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.0.1[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.0.0[${PYTHON_USEDEP}]
"

python_install_all() {
	distutils-r1_python_install_all

	# Upstream's wheel installs \`examples/\` at the site-packages
	# top level, tripping Gentoo's stray-top-level-files check.
	local sp
	for sp in "${ED}"/usr/lib/python*/site-packages; do
		[[ -d ${sp}/examples ]] && rm -r "${sp}/examples" || :
	done
}
