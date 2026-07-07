# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
LLVM_COMPAT=( {18..22} )

inherit distutils-r1 llvm-r2 toolchain-funcs

DESCRIPTION="Python bindings for the MuPDF library"
HOMEPAGE="https://mupdf.com"
SRC_URI="https://mupdf.com/downloads/archive/${P}-source.tar.gz"
S="${WORKDIR}/${P}-source"

LICENSE="AGPL-3"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	~app-text/mupdf-${PV}
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
	')
	dev-python/clang[${PYTHON_USEDEP}]
	dev-lang/swig
"
PATCHES=(
	"${FILESDIR}"/python.diff
	"${FILESDIR}"/mupdf-clang22-has_refs.patch
)

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

_buildpy() {
	"${EPYTHON}" ./scripts/mupdfwrap.py \
		--dir-so "build/shared-release-${EPYTHON}" "${@}" || die
}

python_compile() {
	_buildpy --build 23
}

src_compile() {
	# libmupdfcpp (C++ wrapper around system app-text/mupdf C lib —
	# the python.diff patch keeps libmupdf.so itself out of the build,
	# since we link against system libmupdf instead).
	LD_LIBRARY_PATH="$(get_llvm_prefix)/$(get_libdir)" \
	tc-env_build ./scripts/mupdfwrap.py \
			--dir-so "build/shared-release" \
			--build 01 \
			|| die
	mv build/shared-release/libmupdfcpp.so{,.${PV}} .
	# _mupdf.so (Python C extension via SWIG)
	distutils-r1_src_compile
}

python_test() {
	local -x LD_LIBRARY_PATH="${S}"
	_buildpy --test-python
}

python_install() {
	python_domodule \
		build/shared-release-${EPYTHON}/{_mupdf.so,mupdf.py}
}

python_install_all() {
	dolib.so libmupdfcpp.so*
	doheader -r platform/c++/include/mupdf
}
