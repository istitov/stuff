# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION="7.0"

inherit cmake cuda rocm linux-info

TINY_LLAMAS_COMMIT="99dd1a73db5a37100bd4ae633f4cfce6560e1567"

DESCRIPTION="Port of Facebook's LLaMA model in C/C++"
HOMEPAGE="https://github.com/ggml-org/llama.cpp"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ggml-org/llama.cpp.git"
else
	MY_PV="b${PV#0_pre}"
	SRC_URI="https://github.com/ggml-org/llama.cpp/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/llama.cpp-${MY_PV}"
	KEYWORDS="~amd64"
fi

SRC_URI+="
	examples? (
		https://huggingface.co/ggml-org/tiny-llamas/resolve/${TINY_LLAMAS_COMMIT}/stories15M-q4_0.gguf
			-> ggml-org_models_tinyllamas_stories15M-q4_0-${TINY_LLAMAS_COMMIT}.gguf
	)
"

LICENSE="MIT"
SLOT="0"
# ggml also exposes GGML_AVX_VNNI / GGML_AVX512_VNNI / GGML_AVX512_BF16
# (default OFF in cmake). They are NOT wired here — Gentoo has no standard
# cpu_flags_x86_avx_vnni / avx512_vnni / avx512_bf16 USE flags. Sapphire
# Rapids and later miss those kernels; would need custom USE flags.
CPU_FLAGS_X86=( avx avx2 avx512f avx512vbmi bmi2 f16c fma3 sse4_2 )

# wmma USE explained here: https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#hip
IUSE="openblas +openmp blis rocm cuda opencl +openssl vulkan flexiblas wmma examples +webui sycl"
IUSE+=" ${CPU_FLAGS_X86[@]/#/cpu_flags_x86_}"

# The embedded server web UI no longer ships in the source tarball as of
# upstream PR #22937 (~b9163): cmake provisions assets at configure time
# from a Hugging Face bucket (or a local npm build). Enabling 'webui'
# allows that network fetch.
PROPERTIES="webui? ( live )"
RESTRICT="webui? ( network-sandbox )"

REQUIRED_USE="
	?? (
		openblas
		blis
		flexiblas
	)
	wmma? (
		rocm
	)
"

# numpy is used by convert_hf_to_gguf.py
#
# USE=sycl additionally needs a -fsycl-capable C++ compiler (Intel icpx
# from oneAPI, or clang++ with SYCL patches) — not expressible as a
# Portage dep; pkg_setup warns if icpx is absent from PATH.  cmake also
# auto-detects dev-libs/level-zero (faster device-memory path) and
# sci-ml/oneDNN (oneDNN-accelerated kernels) and silently disables each
# if missing — install separately for full performance.
# UNTESTED 2026-05-17: the sycl USE=path has not been end-to-end built
# on this overlay; revisit on first user report.
CDEPEND="
	openblas? ( sci-libs/openblas:= )
	openmp? ( llvm-runtimes/openmp:= )
	blis? ( sci-libs/blis:= )
	flexiblas? ( sci-libs/flexiblas:= )
	rocm? (
		>=dev-util/hip-${ROCM_VERSION}:=
		>=sci-libs/hipBLAS-${ROCM_VERSION}:=
		wmma? (
			>=sci-libs/rocWMMA-${ROCM_VERSION}:=
		)
	)
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	sycl? ( sci-libs/mkl:= )
	openssl? ( dev-libs/openssl:= )
"
DEPEND="${CDEPEND}
	opencl? ( dev-util/opencl-headers )
	vulkan? (
		dev-util/spirv-headers
		dev-util/vulkan-headers
	)
"
RDEPEND="${CDEPEND}
	dev-python/numpy
	opencl? ( dev-libs/opencl-icd-loader )
	vulkan? ( media-libs/vulkan-loader )
"
BDEPEND="vulkan? ( media-libs/shaderc )"

pkg_setup() {
	# No reliable way to test the system C++ compiler for SYCL support
	# from an ebuild — cmake's check_cxx_compiler_flag(-fsycl) decides at
	# configure time. icpx is the common SYCL toolchain; absence usually
	# means oneAPI isn't installed and the build will fatal-error.
	if use sycl && ! type -P icpx &>/dev/null; then
		ewarn "USE=sycl: Intel icpx (from oneAPI) is not on PATH. If your"
		ewarn "system clang++ has -fsycl support, ignore this; otherwise"
		ewarn "install oneAPI before continuing or cmake will fatal-error."
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

src_prepare() {
	use cuda && cuda_src_prepare
	cmake_src_prepare
	if use examples; then
		mkdir -p "${BUILD_DIR}/tinyllamas" || die
		cp "${DISTDIR}/ggml-org_models_tinyllamas_stories15M-q4_0-${TINY_LLAMAS_COMMIT}.gguf" \
			"${BUILD_DIR}/tinyllamas/stories15M-q4_0.gguf" || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DLLAMA_BUILD_TESTS=OFF
		-DLLAMA_BUILD_EXAMPLES=$(usex examples)
		-DLLAMA_BUILD_SERVER=ON
		# webui gates two independent things since b9413: LLAMA_BUILD_UI
		# builds/embeds the server web UI, and LLAMA_USE_PREBUILT_UI lets
		# scripts/ui-assets.cmake fetch the prebuilt bundle from the HF
		# bucket. Both must track USE=webui: the script's HF-download step
		# is gated only on HF_ENABLED (no BUILD_UI guard), so UI=off with
		# PREBUILT_UI=on would still hit the network and break the sandbox.
		# (LLAMA_BUILD_WEBUI is a deprecated alias for LLAMA_BUILD_UI now.)
		-DLLAMA_BUILD_UI=$(usex webui)
		-DLLAMA_USE_PREBUILT_UI=$(usex webui)
		-DCMAKE_SKIP_BUILD_RPATH=ON
		-DGGML_NATIVE=0	# don't set march
		-DGGML_RPC=ON
		-DLLAMA_OPENSSL=$(usex openssl)
		-DLLAMA_BUILD_NUMBER="${PV#0_pre}"
		-DLLAMA_BUILD_COMMIT="b${PV#0_pre}"
		-DGENTOO_REMOVE_CMAKE_BLAS_HACK=ON
		-DGGML_CUDA=$(usex cuda)
		-DGGML_CUDA_NCCL=OFF
		-DGGML_OPENCL=$(usex opencl)
		-DGGML_OPENMP=$(usex openmp)
		-DGGML_VULKAN=$(usex vulkan)
		-DGGML_SYCL=$(usex sycl)

		# avoid clashing with whisper.cpp
		-DCMAKE_INSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)/llama.cpp"
		-DCMAKE_INSTALL_RPATH="${EPREFIX}/usr/$(get_libdir)/llama.cpp"
	)

	mycmakeargs+=(
		-DGGML_SSE42=$(usex cpu_flags_x86_sse4_2)
		-DGGML_AVX=$(usex cpu_flags_x86_avx)
		-DGGML_AVX2=$(usex cpu_flags_x86_avx2)
		-DGGML_BMI2=$(usex cpu_flags_x86_bmi2)
		-DGGML_F16C=$(usex cpu_flags_x86_f16c)
		-DGGML_FMA=$(usex cpu_flags_x86_fma3)
		-DGGML_AVX512=$(usex cpu_flags_x86_avx512f)
		-DGGML_AVX512_VBMI=$(usex cpu_flags_x86_avx512vbmi)
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
		local -x CUDAHOSTCXX="$(cuda_gccdir)"
		# tries to recreate dev symlinks
		cuda_add_sandbox
		addpredict "/dev/char/"
	fi

	if use rocm; then
		rocm_use_hipcc
		mycmakeargs+=(
			-DGGML_HIP=ON -DAMDGPU_TARGETS=$(get_amdgpu_flags)
			-DGGML_HIP_ROCWMMA_FATTN=$(usex wmma)
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install
	dobin "${BUILD_DIR}/bin/rpc-server"

	# avoid clashing with whisper.cpp
	rm -rf "${ED}/usr/include"
}
