# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Play and record sound with Python — CFFI bindings for PortAudio"
HOMEPAGE="
	https://python-sounddevice.readthedocs.io/
	https://github.com/spatialaudio/python-sounddevice
	https://pypi.org/project/sounddevice/
"
SRC_URI="https://github.com/spatialaudio/python-${PN}/archive/refs/tags/${PV}.tar.gz
	-> ${P}.gh.tar.gz"
S="${WORKDIR}/python-${PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="numpy"

# CFFI runtime dlopen — system libportaudio is loaded at module import,
# not linked at build time. No C compilation step in this ebuild.
RDEPEND="
	dev-python/cffi[${PYTHON_USEDEP}]
	media-libs/portaudio
	numpy? ( dev-python/numpy[${PYTHON_USEDEP}] )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-python/cffi[${PYTHON_USEDEP}]
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"
