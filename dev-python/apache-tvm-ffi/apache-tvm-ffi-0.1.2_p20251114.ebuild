# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

TVM_FFI_COMMIT="ae346ec92a3c386f1376064ae086aae72947c329"
DLPACK_COMMIT="93c8f2a3c774b84af6f652b1992c48164fae60fc"
LIBBACKTRACE_COMMIT="793921876c981ce49759114d7bb89bb89b2d3a2d"

DESCRIPTION="Lightweight, framework-agnostic FFI module from Apache TVM"
HOMEPAGE="https://github.com/apache/tvm-ffi"
SRC_URI="
	https://github.com/apache/tvm-ffi/archive/${TVM_FFI_COMMIT}.tar.gz
		-> ${P}.gh.tar.gz
	https://github.com/dmlc/dlpack/archive/${DLPACK_COMMIT}.tar.gz
		-> dlpack-${DLPACK_COMMIT}.gh.tar.gz
	https://github.com/ianlancetaylor/libbacktrace/archive/${LIBBACKTRACE_COMMIT}.tar.gz
		-> libbacktrace-${LIBBACKTRACE_COMMIT}.gh.tar.gz
"
S="${WORKDIR}/tvm-ffi-${TVM_FFI_COMMIT}"

LICENSE="Apache-2.0 BSD"
SLOT="0"
KEYWORDS="~amd64"
# Upstream's suite builds extra C++ modules and requires optional ML frameworks.
RESTRICT="test"

RDEPEND="
	>=dev-python/typing-extensions-4.5[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-python/cython-3.0[${PYTHON_USEDEP}]
	>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
"
PATCHES=( "${FILESDIR}/${PN}-0.1.2-gcc16-optional.patch" )

# GitHub archives omit submodules and VCS metadata. Restore the exact submodule
# revisions pinned by this commit and provide a PEP 440 version to setuptools-scm.
export SETUPTOOLS_SCM_PRETEND_VERSION="0.1.2.post20251114"

src_prepare() {
	local submodule
	for submodule in dlpack libbacktrace; do
		if [[ -d 3rdparty/${submodule} ]]; then
			rmdir "3rdparty/${submodule}" || die
		fi
	done

	mv "${WORKDIR}/dlpack-${DLPACK_COMMIT}" 3rdparty/dlpack || die
	mv "${WORKDIR}/libbacktrace-${LIBBACKTRACE_COMMIT}" \
		3rdparty/libbacktrace || die

	distutils-r1_src_prepare
}

# Upstream's pyproject.toml value is replaced by the Gentoo PEP 517 helper's
# cmake.args, so preserve the option that builds the Python extension.
DISTUTILS_ARGS=(
	-DTVM_FFI_BUILD_PYTHON_MODULE=ON
)
