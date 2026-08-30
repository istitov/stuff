# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
ROCM_VERSION=${PV}
# Tracks the ROCm 10.0 cohort's LLVM slot (::gentoo's 7.2.0 ebuild this was
# forked from still says 22). The stack is subslot-pinned as one dependency
# closure, so all of it must be compiled by a single LLVM major.
LLVM_COMPAT=( 23 )

inherit cmake distutils-r1 llvm-r2 prefix rocm

DESCRIPTION="A tool for creating a benchmark-driven GEMMs and tensor contractions code"
HOMEPAGE="https://rocm.docs.amd.com/projects/Tensile/en/latest/src/index.html"

if [[ "${PV}" == 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ROCm/rocm-libraries.git"
	EGIT_BRANCH="develop"
	S="${WORKDIR}/${P}/shared/tensile"
	SLOT="0/9999"
	SLOT_NOLIVE="0/10.0"
else
	# Forked into ::stuff for ROCm 10.0: ::gentoo stops at 7.2.x, but
	# sci-libs/rocBLAS pins dev-util/Tensile:${SLOT}, so a 10.0 rocBLAS needs a
	# matching-subslot Tensile that ::gentoo does not provide.
	#
	# AMD retired the rocm-* release line at rocm-7.2.4 (2026-05-28); the same
	# per-component assets ship under therock-<major.minor> tags now.
	SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/tensile.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/tensile"
	SLOT="0/$(ver_cut 1-2)"
	SLOT_NOLIVE=${SLOT}
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
IUSE="client test"
REQUIRED_USE="client? ( ${ROCM_REQUIRED_USE} )"

# tests can freeze machine depending on gpu/kernel
RESTRICT="test"

RDEPEND="${PYTHON_DEPS}
	client? ( dev-libs/boost:= )
	>=dev-cpp/msgpack-cxx-6.0.0
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/msgpack[${PYTHON_USEDEP}]
	dev-python/joblib[${PYTHON_USEDEP}]
	dev-util/hip:${SLOT_NOLIVE}
	dev-util/rocm-smi:${SLOT_NOLIVE}
	$(llvm_gen_dep "
		llvm-core/clang:\${LLVM_SLOT}
	")
"
DEPEND="${RDEPEND}"
BDEPEND="
	test? (
		dev-python/filelock[${PYTHON_USEDEP}]
		dev-python/joblib[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-{forked,xdist} )
distutils_enable_tests pytest

PATCHES=(
	"${FILESDIR}"/${PN}-5.4.2-fix-arch-parse.patch
	"${FILESDIR}"/${PN}-6.0.2-expand-isa-compatibility.patch
	"${FILESDIR}"/${PN}-7.0.1-fix-install.patch
	"${FILESDIR}"/${PN}-7.1.0-cmake.patch
)

CMAKE_USE_DIR="${S}/${PN}/Source"

src_prepare() {
	distutils-r1_src_prepare
	sed -e "s,\@LLVM_PATH\@,$(get_llvm_prefix),g" \
		"${FILESDIR}/${PN}-5.7.1-gentoopath.patch" > "${S}"/gentoopath.patch || die
	eapply $(prefixify_ro "${S}"/gentoopath.patch)

	pushd "${PN}" || die

	sed -e "/ROCM_SMI_ROOT/s,lib,$(get_libdir)," \
		-i Source/cmake/FindROCmSMI.cmake || die
	sed -r -e "/TENSILE_USE_LLVM/s/ON/OFF/" \
		-i Source/CMakeLists.txt || die

	# ${Tensile_ROOT}/bin does not exists; call command directly
	sed -e "s,\${Tensile_ROOT}/bin/,,g" -i cmake/TensileConfig.cmake || die

	local Tensile_share_dir="\"${EPREFIX}/usr/share/${PN}\""
	sed -e "/HipClangVersion/s/0.0.0/$(hipconfig -v)/" -i Common.py || die

	sed -e "s,os.path.dirname(os.path.realpath(__file__)),${Tensile_share_dir},g" \
		-i ReplacementKernels.py Common.py "${PN}.py" || die

	sed -e "s|os\.path\.dirname.*$|\"${EPREFIX}/usr/share/Tensile/Source\", end='')|" -i __init__.py || die

	# The v_dot4_i32_i8 syntax fix for clang-20 (bug 949817) is upstream at
	# 10.0: Components/MAC_I8X4.py no longer emits the op_sel/op_sel_hi
	# operands this sed used to strip, so it matched nothing. Dropped rather
	# than left as a silent no-op. verified 2026-08-30.

	# Fix compiler "validation"
	rocm_use_clang
	sed "s/amdclang/$(basename "$CC")/g" -i Utilities/Toolchain.py || die

	popd || die

	use client && PATCHES='' cmake_src_prepare  # do not apply patches again in cmake_src_prepare
}

src_configure() {
	rocm_use_clang

	distutils-r1_src_configure
	if use client; then
		local targets="$(get_amdgpu_flags)"
		local mycmakeargs=(
			-DCMAKE_SKIP_RPATH=ON
			-DTENSILE_USE_MSGPACK=ON
			-DTENSILE_USE_LLVM=ON
			-DTensile_LIBRARY_FORMAT=msgpack
			-DGPU_TARGETS="${targets::-1}"
		)
		cmake_src_configure
	fi
}

src_compile() {
	distutils-r1_src_compile
	use client && cmake_src_compile
}

python_install() {
	distutils-r1_python_install

	python_moduleinto Tensile
	pushd Tensile || die
	python_domodule Components
	python_domodule Utilities
	python_domodule TensileCreateLib
}

src_install() {
	distutils-r1_src_install

	pushd "${PN}" || die
	insinto "/usr/share/${PN}"
	doins -r Configs Perf Source CustomKernels
	insinto "/usr/$(get_libdir)/cmake/${PN}"
	doins cmake/*.cmake

	if use client; then
		pushd "${BUILD_DIR}" || die
		dobin client/tensile_client
	fi

	# Remove extra copy
	rm -rf "${ED}"/usr/cmake || die
}

# Test suite fails to start without this
python_test() {
	export ROCM_PATH="${EPREFIX}/usr"
	epytest
}
