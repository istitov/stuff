# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="Python bindings for GLFW"
HOMEPAGE="
	https://github.com/FlorianRhiem/pyGLFW
	https://pypi.org/project/glfw/
"
SRC_URI="https://github.com/FlorianRhiem/pyGLFW/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/pyGLFW-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# ctypes wrapper that dlopens libglfw at runtime.
RDEPEND="media-libs/glfw"
