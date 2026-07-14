# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# supports ROCM/HIP >=5.5, but we define 7.0 to match the rest of the overlay
ROCM_VERSION="7.0"

inherit cuda rocm cmake flag-o-matic go-module linux-info multiprocessing systemd

# Upstream's CMake superbuild (cmake/local.cmake) builds the GGML/llama.cpp
# inference backends from a pinned llama.cpp fetched via ExternalProject. The
# pinned commit lives in the LLAMA_CPP_VERSION file in the ollama source tree;
# we prestage that exact tree as a distfile, patch the ExternalProject download
# to a no-op (ollama-no-llama-cpp-download.patch), and symlink the tree into
# _deps/llama_cpp-src in src_configure so the build never touches the network
# AND upstream's own compat-patch step (llama/compat/**) stays active. Re-check
# on every bump: `cat LLAMA_CPP_VERSION` in the matching ollama tag.
# verified 2026-07-14 (ollama 0.32.0 -> llama.cpp b9888).
LLAMACPP_COMMIT="b9888"

DESCRIPTION="Get up and running with Llama 3, Mistral, Gemma, and other language models"
HOMEPAGE="https://ollama.com"

MY_PV="${PV/_rc/-rc}"
MY_P="${PN}-${MY_PV}"
SRC_URI="
	https://github.com/ollama/${PN}/archive/refs/tags/v${MY_PV}.tar.gz -> ${MY_P}.gh.tar.gz
	https://github.com/gentoo-golang-dist/${PN}/releases/download/v${MY_PV}/${MY_P}-deps.tar.xz
	https://github.com/ggml-org/llama.cpp/archive/refs/tags/${LLAMACPP_COMMIT}.tar.gz
		-> ${PN}-llama.cpp-${LLAMACPP_COMMIT}.tar.gz
"
S="${WORKDIR}/${PN}-${MY_PV}"
LLAMACPP_S="${WORKDIR}/llama.cpp-${LLAMACPP_COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# cuda  -> cuda_v13 llama-server backend (this overlay tracks CUDA 13.x;
#          cuda_v12 is intentionally not wired).
# rocm  -> rocm_v7_2 (Linux) llama-server backend.
# vulkan-> vulkan llama-server backend.
# The CPU backend (all microarch variants) is always built and the right one
# is dlopen'd at runtime, so no cpu_flags_x86 USE flags are needed.
IUSE="cuda rocm vulkan"

# Upstream tests pull models from the network; the dependency tarball is a
# GitHub release asset that must not be mirrored.
RESTRICT="mirror test"

CDEPEND="
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	rocm? (
		>=dev-util/hip-${ROCM_VERSION}:=
		>=sci-libs/hipBLAS-${ROCM_VERSION}:=
		>=sci-libs/rocBLAS-${ROCM_VERSION}:=
	)
"
DEPEND="${CDEPEND}"
BDEPEND="
	>=dev-lang/go-1.26.0
	vulkan? (
		dev-util/vulkan-headers
		media-libs/shaderc
	)
"
RDEPEND="
	${CDEPEND}
	acct-group/${PN}
	>=acct-user/${PN}-3[cuda?]
	vulkan? ( media-libs/vulkan-loader )
"

PATCHES=(
	"${FILESDIR}/ollama-unbundle-gpu-runtime-libs.patch"
	"${FILESDIR}/ollama-rocm-no-parallel-jobs.patch"
	"${FILESDIR}/ollama-no-llama-cpp-download.patch"
	"${FILESDIR}/ollama-nostrip.patch"
)

pkg_pretend() {
	if use cuda || use rocm; then
		# The GPU backend compiles ~600 CUDA/HIP template-instance TUs in a
		# nested cmake sub-build whose job count follows MAKEOPTS (wired via
		# -DOLLAMA_BUILD_PARALLEL in src_configure). Each concurrent nvcc/clang
		# pipeline is memory-hungry, so a high -j on a RAM-constrained host can
		# be OOM-killed mid-compile.
		ewarn "The GPU backend compiles ~600 CUDA/HIP template units; their"
		ewarn "parallelism follows MAKEOPTS. On a RAM-constrained host a high -j"
		ewarn "may be OOM-killed mid-compile -- cap jobs for this package with a"
		ewarn "MAKEOPTS=\"-jN\" line in /etc/portage/env/${CATEGORY}/${PN}"
	fi
}

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
	if use rocm; then
		# ROCm/HIP rejects some LTO flags; filter before the Go env captures
		# them into CGO_*. 963401
		strip-unsupported-flags
		export CXXFLAGS="$(test-flags-HIPCXX "${CXXFLAGS}")"
	fi

	# Unpacks the ollama source, the prestaged llama.cpp tree, and the Go
	# dependency tarball (the latter into GOMODCACHE).
	go-module_src_unpack
}

src_prepare() {
	cmake_src_prepare

	# GCC 17 header hygiene for the bundled llama.cpp: common.h uses
	# std::ofstream without including <fstream>. Applied from the llama.cpp tree
	# so the patch stays independent of the pinned commit.
	pushd "${LLAMACPP_S}" >/dev/null || die
	eapply "${FILESDIR}/${PN}-gcc17-fstream.patch"
	popd >/dev/null || die

	# NB: we do NOT re-apply llama/compat/**/*.patch here. Because the prestaged
	# tree is dropped into _deps/llama_cpp-src via a symlink (see src_configure)
	# rather than FETCHCONTENT_SOURCE_DIR_LLAMA_CPP, OLLAMA_LLAMA_CPP_SKIP_COMPAT_PATCH
	# is not forced on, so upstream's own apply-patch.cmake applies the compat
	# set (the linked-in models/*.patch architectures included).

	# The Go binary resolves its runtime payload at exeDir/../lib/ollama
	# (ml/path.go). We install to $(get_libdir)/ollama (lib64 on multilib), so
	# teach the binary to look there. No-op on lib (32-bit) layouts.
	sed -i -e "s/\"lib\", \"ollama\"/\"$(get_libdir)\", \"ollama\"/g" \
		ml/path.go || die "libdir sed failed"
}

src_configure() {
	local backends=()
	use cuda && backends+=( cuda_v13 )
	use rocm && backends+=( rocm_v7_2 )
	use vulkan && backends+=( vulkan )

	local mycmakeargs=(
		-DOLLAMA_VERSION="${PV}"
		-DOLLAMA_LIB_DIR="$(get_libdir)/ollama"
		-DGGML_CCACHE=OFF
		-DOLLAMA_LLAMA_BACKENDS="$(IFS=';'; echo "${backends[*]}")"
		# Cap the nested llama-server sub-builds' parallelism. cmake/local.cmake
		# runs each backend's `cmake --build --parallel` with NO job count, so
		# those ExternalProject builds ignore MAKEOPTS *and*
		# CMAKE_BUILD_PARALLEL_LEVEL and fan out to the generator default (all
		# cores). For ggml-cuda's ~600 fat template-instance TUs that OOM-kills
		# the compile on constrained-RAM hosts. OLLAMA_BUILD_PARALLEL supplies
		# the missing `--parallel <N>`; tie it to MAKEOPTS so a per-package env
		# job cap governs the nested CUDA/HIP build too.
		-DOLLAMA_BUILD_PARALLEL="$(makeopts_jobs)"
	)

	if use rocm; then
		# Forward the configured GPU arch(s); the superbuild then selects the
		# rocm_v7_2_user_arch preset and passes AMDGPU_TARGETS down to ggml-hip.
		mycmakeargs+=( -DAMDGPU_TARGETS="$(get_amdgpu_flags)" )
	fi

	cmake_src_configure

	# The llama.cpp ExternalProject download is a no-op (see PATCHES); drop the
	# prestaged tree into the source dir the sub-build expects so it patches and
	# compiles our pinned llama.cpp in place instead of cloning from the network.
	rm -rf "${BUILD_DIR}/_deps/llama_cpp-src" || die
	ln -s "${LLAMACPP_S}" "${BUILD_DIR}/_deps/llama_cpp-src" || die
}

src_compile() {
	if use cuda; then
		# nvcc rejects gcc newer than CUDA supports; cuda_gccdir picks a
		# compatible slot. The CUDA backend is built by a nested CMake project
		# (ExternalProject) during this phase, so the host-compiler choice and
		# the device-node sandbox allowances must be in effect here, not in
		# src_configure. CMake reads CUDAHOSTCXX into CMAKE_CUDA_HOST_COMPILER.
		local -x CUDAHOSTCXX
		CUDAHOSTCXX="$(cuda_gccdir)"
		cuda_add_sandbox -w
		addpredict "/dev/char/"
	fi

	if use rocm; then
		# ggml-hip is built by a nested CMake project that uses
		# enable_language(HIP); CMake needs the ROCm clang as the HIP compiler
		# (the hipcc wrapper isn't recognized). Point HIPCXX at the clang ROCm
		# itself uses, leaving CC/CXX as gcc for the CPU backend and Go cgo.
		# Pre-seed the device list so the HIP compiler's GPU enumeration doesn't
		# reach /dev/kfd inside the sandbox (no GPU present at build time).
		local hipclangpath
		hipclangpath="$(hipconfig --hipclangpath 2>/dev/null)" || die "hipconfig failed"
		[[ -x ${hipclangpath}/clang++ ]] || die "ROCm clang not found at ${hipclangpath}"
		local -x HIPCXX="${hipclangpath}/clang++"
		local -x HIP_PATH="${ESYSROOT}/usr"
		local -x ROCM_TARGET_LST="${T}/rocm_targets.lst"
		printf '%s\n' "${AMDGPU_TARGETS[@]}" > "${ROCM_TARGET_LST}" || die
		addpredict /dev/kfd
		addpredict /dev/dri
	fi

	cmake_src_compile
}

src_install() {
	# NB: not cmake_src_install. That runs `cmake --build --target install`,
	# which re-enters the BUILD_ALWAYS llama-server ExternalProjects; since each
	# carries an absolute CMAKE_INSTALL_PREFIX (the superbuild staging dir), the
	# re-run drops a duplicate payload at ${D}/<buildpath> once DESTDIR is set.
	# Running the top-level install script directly installs the Go binary and
	# the already-staged lib/ollama payload without re-entering the sub-builds.
	DESTDIR="${D}" cmake --install "${BUILD_DIR}" || die

	newinitd "${FILESDIR}"/ollama.init "${PN}"
	newconfd "${FILESDIR}"/ollama.confd "${PN}"
	systemd_dounit "${FILESDIR}"/ollama.service
}

pkg_preinst() {
	keepdir /var/log/ollama
	fperms 750 /var/log/ollama
	fowners "${PN}:${PN}" /var/log/ollama
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		einfo "Quick guide:"
		einfo "  ollama serve"
		einfo "  ollama run llama3"
		einfo
		einfo "See available models at https://ollama.com/library"
	fi

	einfo
	einfo "Ollama binds 127.0.0.1 port 11434 by default."
	einfo "Change the bind address with the OLLAMA_HOST environment variable."
	einfo "See https://docs.ollama.com/faq for more info"
	einfo

	if use cuda; then
		einfo "USE=cuda builds the GPU backend for the GPU present at build time"
		einfo "(CMAKE_CUDA_ARCHITECTURES defaults to 'native'). Set CUDAARCHS to"
		einfo "override. The ${PN} user must be in the video group to see devices;"
		einfo "acct-user/${PN}[cuda] arranges this."
	fi
}
