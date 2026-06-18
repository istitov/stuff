# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Fast C++ build tool to import C++ sources as Python modules"
HOMEPAGE="
	https://github.com/FindDefinition/ccimport
	https://pypi.org/project/ccimport/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream also lists 'ninja' (the python build helper) and 'requests'. Neither
# is needed to import prebuilt extension modules (spconv-cuXXX, cumm-cuXXX) --
# they only drive ccimport's JIT compilation path, which is unused here. The
# lone module-level ninja_syntax import is made optional by the patch below.
# verified 2026-06-17
RDEPEND="
	dev-python/pybind11[${PYTHON_USEDEP}]
"

PATCHES=(
	"${FILESDIR}/ccimport-0.4.4-optional-ninja-syntax.patch"
)

src_prepare() {
	# Upstream's sdist omits version.txt (a source-tree build artifact) yet
	# setup.py reads it because the VERSION constant is left unset. Recreate it.
	echo "${PV}" > version.txt || die
	distutils-r1_src_prepare
}
