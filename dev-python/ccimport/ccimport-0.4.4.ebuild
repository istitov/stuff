# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Fast C++ build tool to import C++ sources as Python modules"
HOMEPAGE="
	https://github.com/FindDefinition/ccimport
	https://pypi.org/project/ccimport/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Keep ninja and requests for JIT compilation; make the module-level
# ninja_syntax import optional so prebuilt modules import without Python ninja.
# verified 2026-06-17
RDEPEND="
	dev-build/ninja
	dev-python/pybind11[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
"

PATCHES=(
	"${FILESDIR}/ccimport-0.4.4-optional-ninja-syntax.patch"
)

src_prepare() {
	# Recreate version.txt, omitted from the sdist but required by setup.py.
	echo "${PV}" > version.txt || die
	distutils-r1_src_prepare
}
