# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Text-to-phones converter — fork of bootphon/phonemizer"
HOMEPAGE="
	https://github.com/bootphon/phonemizer
	https://pypi.org/project/phonemizer-fork/
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# phonemizer-fork is a re-published fork of bootphon/phonemizer to PyPI;
# the upstream project_urls still point at bootphon's repo. PyPI sdist
# is the canonical source for the fork.
RDEPEND="
	${PYTHON_DEPS}
	app-accessibility/espeak-ng
	>=dev-python/attrs-18.1[${PYTHON_USEDEP}]
	dev-python/dlinfo[${PYTHON_USEDEP}]
	dev-python/joblib[${PYTHON_USEDEP}]
	dev-python/segments[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}"
