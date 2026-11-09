# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Evaluator of Python expression using ast module"
HOMEPAGE="
	https://lmfit.github.io/asteval/
	https://github.com/lmfit/asteval/
	https://pypi.org/project/asteval/
"

LICENSE="MIT"
SLOT="0"
# Same-version copy of ::gentoo's 1.0.10, carried only for ~arm64, which
# ::gentoo lacks; sitka-spruce needs it there. Drop it once ::gentoo
# keywords arm64. verified 2026-11-09
KEYWORDS="~amd64 ~arm64"

BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	epytest -o addopts=
}
