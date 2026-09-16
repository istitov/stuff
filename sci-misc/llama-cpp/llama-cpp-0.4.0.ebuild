# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION="7.0"

inherit cmake cuda rocm linux-info toolchain-funcs

TINY_LLAMAS_COMMIT="99dd1a73db5a37100bd4ae633f4cfce6560e1567"

DESCRIPTION="Port of Facebook's LLaMA model in C/C++"
HOMEPAGE="https://github.com/ggml-org/llama.cpp"

# The upstream tag this ebuild builds and the build number that goes with
# it: a release is the vX.Y.Z tag, whose build upstream publishes as
# nightly-tag.txt; a snapshot is the bN tag itself and is versioned
# X.Y.Z_pN after the release it follows.
LLAMA_SRC_TAG="v0.4.0"
LLAMA_BUILD_NUMBER="10809"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ggml-org/llama.cpp.git"
	# No pinned UI distfile exists for a live checkout; CMake builds it with npm
	# or fetches it from Hugging Face.
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

IUSE="openblas +openmp blis rocm cuda opencl +openssl vulkan flexiblas examples +webui sycl"
IUSE+=" ${CPU_FLAGS_X86[@]/#/cpu_flags_x86_}"

REQUIRED_USE="
	?? (
		openblas
		blis
		flexiblas
	)
	rocm? ( ${ROCM_REQUIRED_USE} )
"

# numpy is used by convert_hf_to_gguf.py.
# SYCL needs an unexpressible -fsycl compiler; level-zero and oneDNN are optional
# auto-detected accelerators. End-to-end path untested as of 2026-05-17.
CDEPEND="
	openblas? ( sci-libs/openblas:= )
	openmp? ( llvm-runtimes/openmp:= )
	blis? ( sci-libs/blis:= )
	flexiblas? ( sci-libs/flexiblas:= )
	rocm? (
		>=dev-util/hip-${ROCM_VERSION}:=
		>=sci-libs/hipBLAS-${ROCM_VERSION}:=[${ROCM_USEDEP}]
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

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp

	# CMake tests -fsycl; missing icpx usually predicts configure failure.
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
	# Assets in tools/ui/dist take priority over the npm build and the
	# Hugging Face download, bug #979245.
	if use webui && [[ ${PV} != *9999* ]]; then
		cp -a "${WORKDIR}/${LLAMA_UI}" "${S}/tools/ui/dist" || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DLLAMA_BUILD_TESTS=OFF
		-DLLAMA_BUILD_EXAMPLES=$(usex examples)
		-DLLAMA_BUILD_SERVER=ON
		-DCMAKE_SKIP_BUILD_RPATH=ON
		-DGGML_NATIVE=0	# don't set march
		-DGGML_RPC=ON
		-DLLAMA_OPENSSL=$(usex openssl)
		-DGENTOO_REMOVE_CMAKE_BLAS_HACK=ON
		-DGGML_CUDA=$(usex cuda)
		-DGGML_CUDA_NCCL=OFF
		-DGGML_OPENCL=$(usex opencl)
		-DGGML_OPENMP=$(usex openmp)
		-DGGML_VULKAN=$(usex vulkan)
		-DGGML_SYCL=$(usex sycl)

		# Isolate libraries shared with whisper.cpp.
		-DCMAKE_INSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)/llama.cpp"
		-DCMAKE_INSTALL_RPATH="${EPREFIX}/usr/$(get_libdir)/llama.cpp"
	)

	if [[ ${PV} == *9999* ]]; then
		# Both switches track USE: the Hugging Face fetch runs even with the
		# UI build disabled.
		mycmakeargs+=(
			-DLLAMA_BUILD_UI=$(usex webui)
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
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Both projects install conflicting ggml headers.
	rm -r "${ED}/usr/include" || die
}
