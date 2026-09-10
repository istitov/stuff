# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_USE_PEP517=setuptools
ROCM_VERSION=${PV}
# Keep the subslot-pinned ROCm closure on one LLVM major.
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
	# rocBLAS requires a matching Tensile subslot absent from ::gentoo.
	# AMD moved post-7.2.4 component assets to therock-* tags.
	SRC_URI="https://github.com/ROCm/rocm-libraries/releases/download/therock-$(ver_cut 1-2)/tensile.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/tensile"
	SLOT="0/$(ver_cut 1-2)"
	SLOT_NOLIVE=${SLOT}
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
IUSE="client"
REQUIRED_USE="client? ( ${ROCM_REQUIRED_USE} )"

# Tests can freeze the machine on some GPU/kernel combinations.
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

PATCHES=(
	"${FILESDIR}"/${PN}-5.4.2-fix-arch-parse.patch
	"${FILESDIR}"/${PN}-6.0.2-expand-isa-compatibility.patch
	"${FILESDIR}"/${PN}-7.0.1-fix-install.patch
	"${FILESDIR}"/${PN}-7.1.0-cmake.patch
)

CMAKE_USE_DIR="${S}/${PN}/Source"

src_prepare() {
	# Guard substitutions because sed succeeds on missing anchors. Anchors
	# verified 2026-08-30 against therock-10.0.
	distutils-r1_src_prepare
	grep -qF '@LLVM_PATH@' "${FILESDIR}/${PN}-5.7.1-gentoopath.patch" ||
		die "@LLVM_PATH@ placeholder gone from gentoopath.patch; the generated patch would keep the literal placeholder"
	sed -e "s,\@LLVM_PATH\@,$(get_llvm_prefix),g" \
		"${FILESDIR}/${PN}-5.7.1-gentoopath.patch" > "${S}"/gentoopath.patch || die
	eapply $(prefixify_ro "${S}"/gentoopath.patch)

	pushd "${PN}" || die

	grep -qF 'ROCM_SMI_ROOT' Source/cmake/FindROCmSMI.cmake ||
		die "ROCM_SMI_ROOT anchor moved; rocm_smi would be searched under the wrong libdir"
	sed -e "/ROCM_SMI_ROOT/s,lib,$(get_libdir)," \
		-i Source/cmake/FindROCmSMI.cmake || die
	grep -qF 'TENSILE_USE_LLVM' Source/CMakeLists.txt ||
		die "TENSILE_USE_LLVM anchor moved; the LLVM path would stay enabled"
	sed -r -e "/TENSILE_USE_LLVM/s/ON/OFF/" \
		-i Source/CMakeLists.txt || die

	# Commands are installed outside nonexistent ${Tensile_ROOT}/bin.
	grep -qF '${Tensile_ROOT}/bin/' cmake/TensileConfig.cmake ||
		die "Tensile_ROOT/bin anchor moved; consumers would invoke a nonexistent path"
	sed -e "s,\${Tensile_ROOT}/bin/,,g" -i cmake/TensileConfig.cmake || die

	local Tensile_share_dir="\"${EPREFIX}/usr/share/${PN}\""
	grep -q 'HipClangVersion.*0\.0\.0' Common.py ||
		die "HipClangVersion 0.0.0 placeholder moved; Tensile would misdetect compiler capabilities"
	sed -e "/HipClangVersion/s/0.0.0/$(hipconfig -v)/" -i Common.py || die

	local f
	for f in ReplacementKernels.py Common.py "${PN}.py"; do
		grep -qF 'os.path.dirname(os.path.realpath(__file__))' "${f}" ||
			die "share-dir anchor moved in ${f}; Tensile would look for its data beside the installed module"
	done
	sed -e "s,os.path.dirname(os.path.realpath(__file__)),${Tensile_share_dir},g" \
		-i ReplacementKernels.py Common.py "${PN}.py" || die

	grep -qF 'os.path.dirname' __init__.py ||
		die "os.path.dirname anchor moved in __init__.py; the Source path would not be rewritten"
	sed -e "s|os\.path\.dirname.*$|\"${EPREFIX}/usr/share/Tensile/Source\", end='')|" -i __init__.py || die

	# Toolchain.py resolves compiler and assembler by bare name; Gentoo does
	# not install amdclang.
	rocm_use_clang
	grep -qF 'amdclang' Utilities/Toolchain.py ||
		die "amdclang anchor moved in Utilities/Toolchain.py; toolchain validation would look for a compiler that is not installed"
	sed "s/amdclang/$(basename "$CC")/g" -i Utilities/Toolchain.py || die

	popd || die

	# Avoid applying the shared patch list twice.
	use client && PATCHES='' cmake_src_prepare
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

	# Drop duplicate top-level CMake metadata.
	rm -rf "${ED}"/usr/cmake || die
}
