# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION="7.0"

inherit cmake cuda rocm linux-info

# Upstream cuts a release per master commit, tagged master-<build>-<shorthash>
# (e.g. master-767-885f01a). PV=0_pre<build>; MY_COMMIT pins the short hash so
# the tag/S resolve. GGML_COMMIT is the ggml submodule gitlink at that release
# (git ls-tree stable-diffusion.cpp <tag> -- ggml). Re-read both on every bump.
MY_COMMIT="c00a9e9"
GGML_COMMIT="eced84c86f8b012c752c016f7fe789adea168e1e"

DESCRIPTION="Diffusion model (SD, Flux, Wan, Qwen-Image, ...) inference in pure C/C++"
HOMEPAGE="https://github.com/leejet/stable-diffusion.cpp"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/leejet/stable-diffusion.cpp.git"
	# Only ggml is needed at build time: libwebp/libwebm come from system
	# libs (SD_USE_SYSTEM_*) and the server web frontend is not built.
	EGIT_SUBMODULES=( ggml )
else
	MY_PV="master-${PV#0_pre}-${MY_COMMIT}"
	# ggml is a git submodule; GitHub's release tarball omits submodule
	# contents, so fetch leejet's ggml fork separately and stage it in
	# src_unpack. The Manifest hash pins both regardless of fetch host.
	SRC_URI="
		https://github.com/leejet/stable-diffusion.cpp/archive/refs/tags/${MY_PV}.tar.gz
			-> ${P}.tar.gz
		https://github.com/leejet/ggml/archive/${GGML_COMMIT}.tar.gz
			-> ${PN}-ggml-${GGML_COMMIT}.tar.gz
	"
	S="${WORKDIR}/stable-diffusion.cpp-${MY_PV}"
	KEYWORDS="~amd64"
fi

# For the -9999 (git-r3) build the guard added by this patch is a no-op and
# upstream's git describe supplies the version; for tarball builds it lets the
# ebuild inject SDCPP_BUILD_VERSION/COMMIT below.
PATCHES=( "${FILESDIR}/${PN}-embed-version.patch" )

LICENSE="MIT"
SLOT="0"
CPU_FLAGS_X86=( avx avx2 avx512f avx512vbmi bmi2 f16c fma3 sse4_2 )

IUSE="openblas blis flexiblas rocm cuda opencl vulkan wmma webm webp"
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
	wmma? (
		rocm
	)
"

CDEPEND="
	openblas? ( sci-libs/openblas:= )
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
# The scripts/ conversion helpers (numpy/torch/insightface) are dev tools and
# are not installed, so they contribute no runtime deps.
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
		# The release tarball ships an empty ggml/ placeholder for the
		# submodule; drop it and stage leejet's ggml fork where
		# add_subdirectory(ggml) expects it.
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
		-DCMAKE_SKIP_BUILD_RPATH=ON
		-DSD_BUILD_SHARED_LIBS=OFF
		-DSD_BUILD_EXAMPLES=ON	# the sd CLI + sd-server live under examples/
		# The web frontend needs pnpm + a network fetch; disabling it keeps
		# the build deterministic (autodetected pnpm would fetch at build
		# time). sd-server still ships, just without the embedded web UI.
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

		# avoid clashing with whisper.cpp / llama.cpp
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
		# embed the real release (see the embed-version patch); the tarball
		# is not a git checkout so upstream would report "unknown" otherwise.
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
		local -x CUDAHOSTCXX="$(cuda_gccdir)"
		# tries to recreate dev symlinks
		cuda_add_sandbox
		addpredict "/dev/char/"
	fi

	if use rocm; then
		rocm_use_hipcc
		mycmakeargs+=(
			-DSD_HIPBLAS=ON -DAMDGPU_TARGETS=$(get_amdgpu_flags) -DGPU_TARGETS=$(get_amdgpu_flags)
			-DGGML_HIP_ROCWMMA_FATTN=$(usex wmma)
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# avoid clashing with whisper.cpp / llama.cpp
	rm -rf "${ED}/usr/include" || die

	find "${ED}" -name "*.a" -delete || die
}
