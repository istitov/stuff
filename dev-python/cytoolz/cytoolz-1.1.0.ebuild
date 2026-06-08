# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Cython implementation of toolz: high performance functional utilities"
HOMEPAGE="
	https://github.com/pytoolz/cytoolz
	https://pypi.org/project/cytoolz/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=dev-python/toolz-0.8.0[${PYTHON_USEDEP}]"
BDEPEND=">=dev-python/cython-0.29[${PYTHON_USEDEP}]"

distutils_enable_tests pytest

python_test() {
	# Test the installed extension (the source tree ships only .pyx); run
	# from ${T} so cytoolz's strict pyproject pytest config does not apply.
	cd "${T}" || die
	epytest --pyargs cytoolz
}

python_prepare_all() {
	# setuptools-git-versioning derives the version from git, which the
	# PyPI sdist lacks (yielding 0.0.0). Pin it statically and disable the
	# plugin so the build records ${PV}.
	sed -i \
		-e 's/^dynamic = \["version"\]/version = "'${PV}'"/' \
		-e 's/^enabled = true/enabled = false/' \
		pyproject.toml || die
	distutils-r1_python_prepare_all
}
