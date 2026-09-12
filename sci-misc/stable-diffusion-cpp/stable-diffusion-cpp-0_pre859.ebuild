# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION="7.0"

inherit cmake cuda rocm linux-info

# Snapshot tags are master-<build>-<hash>; pin that hash and the tag's ggml
# submodule gitlink on each bump.
MY_COMMIT="7f410a3"
GGML_COMMIT="e20c3a14aa70ee84ca58499814206dd08d8026bc"

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
PATCHES=( "${FILESDIR}/${PN}-embed-version.patch" )

LICENSE="MIT"
SLOT="0"
CPU_FLAGS_X86=( avx avx2 avx512f avx512vbmi bmi2 f16c fma3 sse4_2 )

IUSE="openblas blis flexiblas rocm cuda opencl vulkan webm webp"
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
"

CDEPEND="
	openblas? ( sci-libs/openblas:= )
	blis? ( sci-libs/blis:= )
	flexiblas? ( sci-libs/flexiblas:= )
	rocm? (
		>=dev-util/hip-${ROCM_VERSION}:=
		>=sci-libs/hipBLAS-${ROCM_VERSION}:=
	)
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	webp? ( media-libs/libwebp:= )
	webm? ( media-libs/libwebm:= )
"
DEPEND="${CDEPEND}
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
BDEPEND="vulkan? ( media-libs/shaderc )"

pkg_setup() {
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
	local mycmakeargs=(
		-DGGML_CCACHE=OFF
		-DCMAKE_SKIP_BUILD_RPATH=ON
		-DSD_BUILD_SHARED_LIBS=OFF
		-DSD_BUILD_EXAMPLES=ON	# the sd CLI + sd-server live under examples/
		# Avoid pnpm's network fetch; sd-server still builds without its web UI.
		-DSD_SERVER_BUILD_FRONTEND=OFF
		-DGGML_NATIVE=0	# don't set march
		-DGGML_RPC=ON
		-DSD_CUDA=$(usex cuda)
		-DSD_OPENCL=$(usex opencl)
		-DSD_VULKAN=$(usex vulkan)
		-DSD_WEBP=$(usex webp)
		-DSD_USE_SYSTEM_WEBP=$(usex webp)
		-DSD_WEBM=$(usex webm)
		-DSD_USE_SYSTEM_WEBM=$(usex webm)

		# Isolate libraries shared with whisper.cpp and llama.cpp.
		-DCMAKE_INSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)/stable-diffusion.cpp"
		-DCMAKE_INSTALL_RPATH="${EPREFIX}/usr/$(get_libdir)/stable-diffusion.cpp"
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
		# nvcc recreates device symlinks during detection.
		cuda_add_sandbox
		addpredict "/dev/char/"
	fi

	if use rocm; then
		rocm_use_hipcc
		mycmakeargs+=(
			-DSD_HIPBLAS=ON -DAMDGPU_TARGETS=$(get_amdgpu_flags) -DGPU_TARGETS=$(get_amdgpu_flags)
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# All three projects install conflicting ggml headers.
	rm -rf "${ED}/usr/include" || die

	find "${ED}" -name "*.a" -delete || die
}
