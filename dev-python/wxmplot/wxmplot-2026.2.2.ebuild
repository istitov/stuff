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
# 2026.2.0 grew a hard dependency on dev-python/vispy (image_canvas/line_plot
# import it at module import time), which is ~amd64-only because its own
# freetype-py dep is ~amd64 in ::gentoo -- so this version drops the ~arm64/~x86
# keywords 2026.1.0 carried. verified 2026-07-26
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/wxpython-4.2.3:*[${PYTHON_USEDEP}]
	>=dev-python/wxutils-2026.3.0[${PYTHON_USEDEP}]
	dev-python/darkdetect[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-3.9.0[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	>=dev-python/numpy-2.0[${PYTHON_USEDEP}]
	>=dev-python/pillow-7.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.0[${PYTHON_USEDEP}]
	>=dev-python/pyshortcuts-1.9.8[${PYTHON_USEDEP}]
	>=dev-python/vispy-0.16.2[${PYTHON_USEDEP}]
	>=dev-python/pyopengl-3.1.10[${PYTHON_USEDEP}]
	>=dev-python/pyopengl-accelerate-3.1.10[${PYTHON_USEDEP}]
"
