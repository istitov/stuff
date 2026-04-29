# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Provides advanced wxPython widgets for plotting based on matplotlib"
HOMEPAGE="https://newville.github.io/wxmplot/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/wxpython-4.2.0:*[${PYTHON_USEDEP}]
	>=dev-python/wxutils-2026.1.0[${PYTHON_USEDEP}]
	dev-python/darkdetect[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.9.0[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.26[${PYTHON_USEDEP}]
	>=dev-python/pillow-7.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.0[${PYTHON_USEDEP}]
	>=dev-python/pyshortcuts-1.9.5[${PYTHON_USEDEP}]
"
