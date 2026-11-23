# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Selects rocm.eclass's 10.x target list, the first with gfx1152/gfx1153.
# The hip/hipBLAS floor stays at 7.0 below: ROCM_USEDEP already requires a
# hipBLAS built for every enabled target.
ROCM_VERSION="10.0"
PYTHON_COMPAT=( python3_{12..15} )

inherit cmake cuda flag-o-matic rocm linux-info python-any-r1 toolchain-funcs

TINY_LLAMAS_COMMIT="99dd1a73db5a37100bd4ae633f4cfce6560e1567"

DESCRIPTION="Port of Facebook's LLaMA model in C/C++"
HOMEPAGE="https://github.com/ggml-org/llama.cpp"

# The upstream tag this ebuild builds and the build number that goes with
# it: a release is the vX.Y.Z tag, whose build upstream publishes as
# nightly-tag.txt; a snapshot is the bN tag itself and is versioned
# X.Y.Z_pN after the release it follows.
LLAMA_SRC_TAG="v1.0.0"
LLAMA_BUILD_NUMBER="12359"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ggml-org/llama.cpp.git"
	# No pinned UI distfile exists for a live checkout; CMake fetches it from
	# Hugging Face at build time.
	RESTRICT="webui? ( network-sandbox )"
else
	# A release carries upstream's own version; a snapshot is a dev build.
	[[ ${LLAMA_SRC_TAG} == v* ]] && LLAMA_BUILD_IS_DEV=OFF || LLAMA_BUILD_IS_DEV=ON
	MY_PV="${LLAMA_SRC_TAG}"
	S="${WORKDIR}/llama.cpp-${LLAMA_SRC_TAG#v}"
	LLAMA_UI="llama-b${LLAMA_BUILD_NUMBER}"
	SRC_URI="
		https://github.com/ggml-org/llama.cpp/archive/refs/tags/${LLAMA_SRC_TAG}.tar.gz -> ${P}.tar.gz
		webui? (
			https://github.com/ggml-org/llama.cpp/releases/download/b${LLAMA_BUILD_NUMBER}/${LLAMA_UI}-ui.tar.gz
		)
	"
fi

SRC_URI+="
	examples? (
		https://huggingface.co/ggml-org/tiny-llamas/resolve/${TINY_LLAMAS_COMMIT}/stories15M-q4_0.gguf
			-> ggml-org_models_tinyllamas_stories15M-q4_0-${TINY_LLAMAS_COMMIT}.gguf
	)
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
CPU_FLAGS_X86=(
	amx_bf16 amx_int8 amx_tile avx avx2 avx512_bf16 avx512_vnni avx512f
	avx512vbmi avx_vnni bmi2 f16c fma3 sse4_2
)

IUSE="debug openblas +openmp blis rocm cuda opencl +openssl vulkan flexiblas examples +webui sycl"
IUSE+=" ${CPU_FLAGS_X86[@]/#/cpu_flags_x86_}"

# HIP builds the CUDA backend sources, and ggml registers that backend once.
# USE=sycl sets CC/CXX to icx/icpx for the whole build, while USE=rocm sets
# them to hipcc; sycl with cuda is untested.
REQUIRED_USE="
	?? (
		openblas
		blis
		flexiblas
	)
	?? ( cuda rocm sycl )
	rocm? ( ${ROCM_REQUIRED_USE} )
"

# The SYCL backend needs Intel's icpx, MKL's SYCL BLAS and the GPU build of
# oneDNN, none of which ::gentoo packages, so USE=sycl builds against an
# oneAPI install outside portage (ONEAPI_ROOT, see pkg_setup). The Level Zero
# loader is ::gentoo's. verified 2026-11-23 on oneAPI 2026.2
CDEPEND="
	sycl? ( dev-libs/level-zero:= )
	openblas? ( sci-libs/openblas:= )
	openmp? ( llvm-runtimes/openmp:= )
	blis? ( sci-libs/blis:= )
	flexiblas? ( sci-libs/flexiblas:= )
	rocm? (
		>=dev-util/hip-7.0:=
		>=sci-libs/hipBLAS-7.0:=[${ROCM_USEDEP}]
		>=sci-libs/rocBLAS-7.0:=[${ROCM_USEDEP}]
	)
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	openssl? ( dev-libs/openssl:= )
	opencl? ( dev-libs/opencl-icd-loader )
	vulkan? ( media-libs/vulkan-loader )
"
DEPEND="${CDEPEND}
	opencl? ( dev-util/opencl-headers )
	vulkan? (
		dev-util/spirv-headers
		dev-util/vulkan-headers
	)
"
# oneAPI's libumf (see src_install) links libhwloc.so.15.
RDEPEND="${CDEPEND}
	sycl? ( sys-apps/hwloc )
"
# The OpenCL backend embeds its kernels with a stdlib-only Python script.
# The BLAS backend finds its library through pkg-config.
# The GPU backends compile with the build host's hipcc or nvcc.
BDEPEND="
	opencl? ( ${PYTHON_DEPS} )
	vulkan? ( media-libs/shaderc )
	openblas? ( virtual/pkgconfig )
	blis? ( virtual/pkgconfig )
	flexiblas? ( virtual/pkgconfig )
	rocm? ( >=dev-util/hipcc-7.0 )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	sycl? ( virtual/pkgconfig )
"

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
	use opencl && python-any-r1_pkg_setup

	if use sycl && [[ ${MERGE_TYPE} != binary ]]; then
		: "${ONEAPI_ROOT:=/opt/intel/oneapi}"
		# ::gentoo's sci-libs/mkl also installs /opt/intel/oneapi/mkl/latest
		# with an MKLConfig.cmake, but without the SYCL libraries.
		local f
		for f in compiler/latest/bin/icpx \
			mkl/latest/lib/libmkl_sycl_blas.so \
			dnnl/latest/lib/cmake/dnnl/dnnl-config.cmake; do
			[[ -e ${ONEAPI_ROOT}/${f} ]] && continue
			eerror "USE=sycl needs Intel oneAPI's DPC++/C++ compiler, oneMKL and"
			eerror "oneDNN, installed with Intel's installer. ${ONEAPI_ROOT}/${f}"
			eerror "is missing; set ONEAPI_ROOT (e.g. in package.env) if oneAPI"
			eerror "lives elsewhere than /opt/intel/oneapi."
			die "oneAPI not found under ${ONEAPI_ROOT}"
		done
		# See src_install; without UMF, SYCL still runs, over OpenCL.
		[[ -d ${ONEAPI_ROOT}/umf/latest/lib ]] ||
			ewarn "No ${ONEAPI_ROOT}/umf/latest/lib: SYCL will fall back to OpenCL."
	fi

	if use rocm; then
		linux-info_pkg_setup
		if linux-info_get_any_version && linux_config_exists; then
			if ! linux_chkconfig_present HSA_AMD_SVM; then
				ewarn "To use ROCm/HIP, you need to have HSA_AMD_SVM option enabled in your kernel."
			fi
		fi
	fi
}

PATCHES=(
	# Stock LLVM 23+ rejects __bf16 vectors for the bf16 MFMA builtins;
	# upstream fixed the WMMA half in b11906. verified 2026-11-14
	"${FILESDIR}"/${PN}-0.7.0_p11906-hip-bf16-mfma.patch
)

src_prepare() {
	use cuda && cuda_src_prepare
	cmake_src_prepare
	if use examples; then
		mkdir -p "${BUILD_DIR}/tinyllamas" || die
		cp "${DISTDIR}/ggml-org_models_tinyllamas_stories15M-q4_0-${TINY_LLAMAS_COMMIT}.gguf" \
			"${BUILD_DIR}/tinyllamas/stories15M-q4_0.gguf" || die
	fi
	# Assets in tools/ui/dist take priority over the npm build and the
	# Hugging Face download, bug #979245.
	if use webui && [[ ${PV} != *9999* ]]; then
		cp -a "${WORKDIR}/${LLAMA_UI}" "${S}/tools/ui/dist" || die
	fi
}

src_configure() {
	# Upstream releases build Release, which supplies -DNDEBUG; cmake.eclass
	# blanks CMAKE_*_FLAGS_RELWITHDEBINFO, so it never lands and the plain
	# assert() calls in ggml and llama stay live -- a configuration upstream
	# never exercises. GGML_ASSERT is unconditional, so the ggml consistency
	# checks survive either way. Worth ~1% of token throughput on AVX-512.
	# USE=debug keeps the asserts for diagnosing an abort. # verified 2026-09-21
	if ! use debug; then
		append-cflags "-DNDEBUG"
		append-cxxflags "-DNDEBUG"
	fi

	local d rpath="${EPREFIX}/usr/$(get_libdir)/llama.cpp"
	# The SYCL runtime, SVML, libiomp5, oneMKL, oneDNN and TBB are not on the
	# loader path; find them without sourcing setvars.sh, at link time (the
	# executables link them only indirectly) and at run time. Some of
	# oneAPI's own libraries carry no RUNPATH (its libOpenCL needs libirng)
	# and share sonames with dev-cpp/tbb, sci-ml/oneDNN and
	# opencl-icd-loader, so emit DT_RPATH, which also covers the dependencies
	# of libraries without a RUNPATH, as setvars.sh would.
	# verified 2026-11-23
	if use sycl; then
		for d in compiler mkl dnnl tbb; do
			rpath+=";${ONEAPI_ROOT}/${d}/latest/lib"
			append-ldflags "-Wl,-rpath-link,${ONEAPI_ROOT}/${d}/latest/lib"
		done
		append-ldflags -Wl,--disable-new-dtags
	fi

	local mycmakeargs=(
		-DLLAMA_BUILD_TESTS=OFF
		-DLLAMA_BUILD_EXAMPLES=$(usex examples)
		-DLLAMA_BUILD_SERVER=ON
		-DCMAKE_SKIP_BUILD_RPATH=ON
		-DGGML_NATIVE=0	# don't set march
		-DGGML_RPC=ON
		# Otherwise RPC links libibverbs whenever the build host has it.
		-DGGML_RPC_RDMA=OFF
		# ggml would wrap the compiler in any ccache it finds; Portage's
		# FEATURES=ccache decides that instead.
		-DGGML_CCACHE=OFF
		# llama-connect is only a prebuilt binary fetched at build time.
		-DLLAMA_CONNECT=OFF
		-DLLAMA_OPENSSL=$(usex openssl)
		-DGENTOO_REMOVE_CMAKE_BLAS_HACK=ON
		-DGGML_CUDA=$(usex cuda)
		-DGGML_CUDA_NCCL=OFF
		-DGGML_OPENCL=$(usex opencl)
		# ggml accepts only Adreno and Intel GPUs, and its Adreno kernels reject
		# every other device, so they are enabled only where Adreno exists.
		# verified 2026-10-06
		-DGGML_OPENCL_USE_ADRENO_KERNELS=$(usex arm64)
		-DGGML_OPENMP=$(usex openmp)
		-DGGML_VULKAN=$(usex vulkan)
		-DGGML_SYCL=$(usex sycl)

		# Isolate libraries shared with whisper.cpp.
		-DCMAKE_INSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)/llama.cpp"
		-DCMAKE_INSTALL_RPATH="${rpath}"
	)

	if [[ ${PV} == *9999* ]]; then
		# USE=webui fetches upstream's prebuilt UI from Hugging Face (the
		# checkout's build number, else "latest"). The npm build stays off:
		# it would run only when the build host happens to have npm.
		mycmakeargs+=(
			-DLLAMA_BUILD_UI=OFF
			-DLLAMA_USE_PREBUILT_UI=$(usex webui)
		)
	else
		mycmakeargs+=(
			# Never provision the UI over the network; without the distfile
			# the server is built with an empty UI.
			-DLLAMA_BUILD_UI=OFF
			-DLLAMA_USE_PREBUILT_UI=OFF
			-DLLAMA_BUILD_IS_DEV=${LLAMA_BUILD_IS_DEV}
			-DLLAMA_BUILD_NUMBER="${LLAMA_BUILD_NUMBER}"
			-DLLAMA_BUILD_COMMIT="${MY_PV}"
		)
	fi

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
		# nvcc recreates device symlinks during detection.
		cuda_add_sandbox
		addpredict "/dev/char/"
	fi

	if use rocm; then
		rocm_use_hipcc
		mycmakeargs+=(
			-DGGML_HIP=ON -DAMDGPU_TARGETS=$(get_amdgpu_flags)
		)
		# hipcc 10.1 hides libomp from CMake; see rocm_hipcc_openmp_args.
		use openmp && mycmakeargs+=( $(rocm_hipcc_openmp_args) )
	fi

	if use sycl; then
		# ggml-sycl checks ENV{ONEAPI_ROOT} to tell icpx from a SYCL clang.
		export ONEAPI_ROOT
		export PATH="${ONEAPI_ROOT}/compiler/latest/bin:${PATH}"
		export CC=icx CXX=icpx
		strip-unsupported-flags
		# Point at oneAPI's MKL and oneDNN explicitly: ::gentoo's sci-libs/mkl
		# (no SYCL BLAS, and its env.d exports MKLROOT, which MKLConfig
		# prefers) and CPU-only sci-ml/oneDNN would otherwise be found, and
		# ggml-sycl rejects a oneDNN without DNNL_GPU_VENDOR.
		# verified 2026-11-23
		mycmakeargs+=(
			-DGGML_SYCL_TARGET=INTEL
			-DGGML_SYCL_F16=ON
			-DMKL_ROOT="${ONEAPI_ROOT}/mkl/latest"
			-DMKL_DIR="${ONEAPI_ROOT}/mkl/latest/lib/cmake/mkl"
			-DDNNL_DIR="${ONEAPI_ROOT}/dnnl/latest/lib/cmake/dnnl"
			# oneDNN's config would otherwise take dev-cpp/tbb's.
			-DTBB_DIR="${ONEAPI_ROOT}/tbb/latest/lib/cmake/tbb"
		)
	fi

	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	# A failed fetch only warns and builds the server without a UI. Assets
	# placed in the checkout's tools/ui/dist (e.g. by a user patch) are
	# embedded from there instead.
	if [[ ${PV} == *9999* ]] && use webui &&
		[[ ! -f ${BUILD_DIR}/tools/ui/dist/index.html &&
		! -f ${S}/tools/ui/dist/index.html ]]; then
		die "USE=webui: the prebuilt UI could not be fetched from Hugging Face"
	fi
}

src_install() {
	cmake_src_install

	# Both projects install conflicting ggml headers.
	rm -r "${ED}/usr/include" || die

	# The SYCL runtime's Level Zero adapter finds libumf only through the
	# loader path (its RUNPATH is $ORIGIN, which overrides our RPATH);
	# without it SYCL silently falls back to OpenCL. verified 2026-11-23
	if use sycl; then
		newenvd - 99${PN}-sycl <<-EOF
			LDPATH="${ONEAPI_ROOT}/umf/latest/lib"
		EOF
	fi
}
