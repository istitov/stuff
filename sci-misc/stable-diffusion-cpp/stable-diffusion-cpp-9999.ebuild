# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION="7.0"
PYTHON_COMPAT=( python3_{12..15} )

inherit cmake cuda flag-o-matic rocm linux-info python-any-r1 toolchain-funcs

# Snapshot tags are master-<build>-<hash>; pin that hash and the tag's ggml
# submodule gitlink on each bump.
MY_COMMIT="532d2c1"
GGML_COMMIT="eeda9ec48fc84a3df0bb9dcc19ae9053075a2539"

DESCRIPTION="Diffusion model (SD, Flux, Wan, Qwen-Image, ...) inference in pure C/C++"
HOMEPAGE="https://github.com/leejet/stable-diffusion.cpp"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/leejet/stable-diffusion.cpp.git"
	# Other submodules are replaced by system libraries or disabled.
	EGIT_SUBMODULES=( ggml )
else
	MY_PV="master-${PV#0_pre}-${MY_COMMIT}"
	# GitHub tarballs omit ggml; fetch its pinned gitlink separately.
	SRC_URI="
		https://github.com/leejet/stable-diffusion.cpp/archive/refs/tags/${MY_PV}.tar.gz
			-> ${P}.tar.gz
		https://github.com/leejet/ggml/archive/${GGML_COMMIT}.tar.gz
			-> ${PN}-ggml-${GGML_COMMIT}.tar.gz
	"
	S="${WORKDIR}/stable-diffusion.cpp-${MY_PV}"
	KEYWORDS="~amd64 ~arm64"
fi

# Let tarballs inject version metadata; live builds retain git describe.
PATCHES=(
	"${FILESDIR}/${PN}-embed-version.patch"
	# ROCm 10.1's stock LLVM 23 rejects __bf16 vectors for the bf16 MFMA
	# builtins in the bundled ggml, whose pin already carries the WMMA half
	# of the fix; same patch as sci-misc/llama-cpp. verified 2026-11-16 at
	# ggml eeda9ec4
	"${FILESDIR}/${PN}-0_pre1104-hip-bf16-mfma.patch"
	# Built without an architecture, the CUTLASS kernels crash on an
	# RTX A4500 (sm_86). verified 2026-11-02
	"${FILESDIR}/${PN}-0_pre1039-cuda-architectures.patch"
)

# Bundled Oniguruma is BSD-2; utf8proc is MIT with Unicode data; darts-clone
# is BSD; kuba--/zip is Unlicense. verified 2026-10-22
LICENSE="MIT BSD BSD-2 Unicode-DFS-2016 Unlicense"
SLOT="0"
CPU_FLAGS_X86=(
	amx_bf16 amx_int8 amx_tile avx avx2 avx512_bf16 avx512_vnni avx512f
	avx512vbmi avx_vnni bmi2 f16c fma3 sse4_2
)

IUSE="debug openblas +openmp blis flexiblas hipblaslt rocm cuda opencl vulkan webm webp"
IUSE+=" ${CPU_FLAGS_X86[@]/#/cpu_flags_x86_}"

REQUIRED_USE="
	?? (
		openblas
		blis
		flexiblas
	)
	webm? (
		webp
	)
	hipblaslt? ( rocm )
"

CDEPEND="
	openblas? ( sci-libs/openblas:= )
	blis? ( sci-libs/blis:= )
	flexiblas? ( sci-libs/flexiblas:= )
	rocm? (
		>=dev-util/hip-${ROCM_VERSION}:=
		>=sci-libs/hipBLAS-${ROCM_VERSION}:=
		openmp? ( llvm-runtimes/openmp:= )
		hipblaslt? ( >=sci-libs/hipBLASLt-${ROCM_VERSION}:= )
	)
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	webp? ( media-libs/libwebp:= )
	webm? ( media-libs/libwebm:= )
"
DEPEND="${CDEPEND}
	cuda? ( dev-libs/cutlass )
	opencl? ( dev-util/opencl-headers )
	vulkan? (
		dev-util/spirv-headers
		dev-util/vulkan-headers
	)
"
RDEPEND="${CDEPEND}
	opencl? ( dev-libs/opencl-icd-loader )
	vulkan? ( media-libs/vulkan-loader )
"
# Uninstalled conversion scripts do not add runtime dependencies.
# The OpenCL backend embeds its kernels with a stdlib-only Python script.
BDEPEND="
	opencl? ( ${PYTHON_DEPS} )
	vulkan? ( media-libs/shaderc )
"

# hipcc builds against LLVM's libomp, declared under rocm; otherwise the
# toolchain's own OpenMP runtime is used.
pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && ! use rocm && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && ! use rocm && tc-check-openmp
	use opencl && python-any-r1_pkg_setup
	if use rocm; then
		linux-info_pkg_setup
		if linux-info_get_any_version && linux_config_exists; then
			if ! linux_chkconfig_present HSA_AMD_SVM; then
				ewarn "To use ROCm/HIP, you need to have HSA_AMD_SVM option enabled in your kernel."
			fi
		fi
	fi
}

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
	else
		default
		# Replace the empty submodule placeholder with the pinned ggml tree.
		rm -rf "${S}/ggml" || die
		mv "${WORKDIR}/ggml-${GGML_COMMIT}" "${S}/ggml" || die
	fi
}

src_prepare() {
	use cuda && cuda_src_prepare
	cmake_src_prepare
}

src_configure() {
	# Upstream releases build Release, which supplies -DNDEBUG; cmake.eclass
	# blanks CMAKE_*_FLAGS_RELWITHDEBINFO, so it never lands and the plain
	# assert() calls in the vendored ggml stay live -- a configuration upstream
	# never exercises. GGML_ASSERT is unconditional, so the bulk of this tree's
	# own checks survive either way. USE=debug keeps the plain asserts for
	# diagnosing an abort. # verified 2026-09-21
	if ! use debug; then
		append-cflags "-DNDEBUG"
		append-cxxflags "-DNDEBUG"
	fi

	local mycmakeargs=(
		-DGGML_CCACHE=OFF
		-DCMAKE_SKIP_BUILD_RPATH=ON
		-DSD_BUILD_SHARED_LIBS=OFF
		-DSD_BUILD_EXAMPLES=ON	# the sd CLI + sd-server live under examples/
		# Avoid pnpm's network fetch; sd-server still builds without its web UI.
		-DSD_SERVER_BUILD_FRONTEND=OFF
		-DGGML_NATIVE=0	# don't set march
		-DGGML_RPC=ON
		# ggml enables OpenMP by default whenever the compiler supports it.
		-DGGML_OPENMP=$(usex openmp)
		-DSD_CUDA=$(usex cuda)
		-DSD_OPENCL=$(usex opencl)
		# ggml accepts only Adreno and Intel GPUs, and its Adreno kernels reject
		# every other device, so they are enabled only where Adreno exists.
		# verified 2026-10-06
		-DGGML_OPENCL_USE_ADRENO_KERNELS=$(usex arm64)
		-DSD_VULKAN=$(usex vulkan)
		-DSD_WEBP=$(usex webp)
		-DSD_USE_SYSTEM_WEBP=$(usex webp)
		-DSD_WEBM=$(usex webm)
		-DSD_USE_SYSTEM_WEBM=$(usex webm)

		# A private libdir keeps the static build's leftovers apart from the
		# system's; src_install removes it.
		-DCMAKE_INSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)/stable-diffusion.cpp"
	)

	mycmakeargs+=(
		-DGGML_SSE42=$(usex cpu_flags_x86_sse4_2)
		-DGGML_AVX=$(usex cpu_flags_x86_avx)
		-DGGML_AVX_VNNI=$(usex cpu_flags_x86_avx_vnni)
		-DGGML_AVX2=$(usex cpu_flags_x86_avx2)
		-DGGML_BMI2=$(usex cpu_flags_x86_bmi2)
		-DGGML_F16C=$(usex cpu_flags_x86_f16c)
		-DGGML_FMA=$(usex cpu_flags_x86_fma3)
		-DGGML_AVX512=$(usex cpu_flags_x86_avx512f)
		-DGGML_AVX512_VBMI=$(usex cpu_flags_x86_avx512vbmi)
		-DGGML_AVX512_VNNI=$(usex cpu_flags_x86_avx512_vnni)
		-DGGML_AVX512_BF16=$(usex cpu_flags_x86_avx512_bf16)
		-DGGML_AMX_TILE=$(usex cpu_flags_x86_amx_tile)
		-DGGML_AMX_INT8=$(usex cpu_flags_x86_amx_int8)
		-DGGML_AMX_BF16=$(usex cpu_flags_x86_amx_bf16)
	)

	if [[ ${PV} != *9999* ]]; then
		# Tarballs lack git metadata, so inject the release identity.
		mycmakeargs+=(
			-DSDCPP_BUILD_VERSION="${MY_PV}"
			-DSDCPP_BUILD_COMMIT="${MY_COMMIT}"
		)
	fi

	if use openblas ; then
		mycmakeargs+=(
			-DGGML_BLAS=ON -DGGML_BLAS_VENDOR=OpenBLAS
		)
	fi

	if use blis ; then
		mycmakeargs+=(
			-DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME
		)
	fi

	if use flexiblas; then
		mycmakeargs+=(
			-DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FlexiBLAS
		)
	fi

	if use cuda; then
		local -x CUDAHOSTCXX="$(cuda_gccdir)/g++"
		# ggml autodetects and links NCCL, which is unpackaged. verified 2026-10-22
		# Only the ggml submodule is fetched, so thirdparty/cutlass stays empty,
		# which is a configure error. The path cannot be /usr: it would put
		# /usr/include on nvcc's system include list, ahead of what libstdc++
		# needs for its #include_next of math.h. verified 2026-11-01
		local cutlass="${T}/cutlass"
		mkdir -p "${cutlass}/include" || die
		ln -s "${ESYSROOT}"/usr/include/{cutlass,cute} "${cutlass}/include/" || die
		mycmakeargs+=(
			-DGGML_CUDA_NCCL=OFF
			-DSD_CUDA_CUTLASS_PATH="${cutlass}"
		)
		# nvcc recreates device symlinks during detection.
		cuda_add_sandbox
		addpredict "/dev/char/"
	fi

	if use rocm; then
		rocm_use_hipcc
		mycmakeargs+=(
			-DSD_HIPBLAS=ON -DAMDGPU_TARGETS=$(get_amdgpu_flags) -DGPU_TARGETS=$(get_amdgpu_flags)
		)
		# hipcc 10.1 hides libomp from CMake; see rocm_hipcc_openmp_args.
		use openmp && mycmakeargs+=( $(rocm_hipcc_openmp_args) )
		# The int8 GEMM links hipBLASLt whenever CMake finds it (package
		# version 1.0 or newer); USE=hipblaslt decides instead. verified
		# 2026-11-15
		mycmakeargs+=(
			-DCMAKE_DISABLE_FIND_PACKAGE_hipblaslt=$(usex hipblaslt OFF ON)
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Install the two programs only. ggml and libstable-diffusion are static
	# and linked into them, their headers conflict with whisper.cpp and
	# llama.cpp, and the cmake and pkg-config files describe those removed
	# libraries. LICENSE covers the third-party license files. verified
	# 2026-11-16
	rm -r "${ED}/usr/include" "${ED}/usr/$(get_libdir)/stable-diffusion.cpp" \
		"${ED}/usr/share/licenses" || die
}
