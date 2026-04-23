# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Small-angle scattering theory models for bumps and SasView"
HOMEPAGE="
	https://github.com/SasView/sasmodels
	https://pypi.org/project/sasmodels/
	https://www.sasview.org/docs/
"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64"
IUSE="opencl cuda"

RDEPEND="
	dev-python/bumps[${PYTHON_USEDEP}]
	dev-python/columnize[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/siphash24[${PYTHON_USEDEP}]
	dev-python/tccbox[${PYTHON_USEDEP}]
	opencl? ( dev-python/pyopencl[${PYTHON_USEDEP}] )
	cuda? (
		dev-python/pycuda[${PYTHON_USEDEP}]
		dev-util/nvidia-cuda-toolkit
	)
"
BDEPEND="
	dev-python/hatch-requirements-txt[${PYTHON_USEDEP}]
	dev-python/hatch-sphinx[${PYTHON_USEDEP}]
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
	dev-python/docutils[${PYTHON_USEDEP}]
	dev-python/sphinx[${PYTHON_USEDEP}]
"

src_prepare() {
	# Drop all [[tool.hatch.build.targets.wheel.hooks.sphinx.tools]]
	# array-of-tables blocks and the force-include of build/doc that
	# the sphinx hook was supposed to create.
	sed -i \
		-e '/^\[\[tool\.hatch\.build\.targets\.wheel\.hooks\.sphinx/,/^\[[^[]/{/^\[[^[]/!d}' \
		-e '/^\[tool\.hatch\.build\.targets\.wheel\.force-include\]/,/^\[/{/build\/doc/d}' \
		pyproject.toml || die
	distutils-r1_src_prepare
}
