# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Match the overlay stack despite upstream supporting ROCm 5.5+.
ROCM_VERSION="7.0"

inherit cuda rocm cmake flag-o-matic go-module linux-info multiprocessing systemd

# Prestage the exact llama.cpp pin from LLAMA_CPP_VERSION, while preserving
# upstream's compat-patch step. Recheck every bump; v0.33.3 moved the pin from
# b10630 to b10760. verified 2026-09-04
LLAMACPP_COMMIT="b10760"

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
KEYWORDS="~amd64 ~arm64"

# GPU flags select cuda_v13, rocm_v7_2, or vulkan; CPU microarchitecture
# variants are always built and selected at runtime.
IUSE="cuda openrc rocm systemd vulkan"

# Tests fetch models; the dependency release asset must not be mirrored.
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
		# Nested GPU builds compile ~600 memory-heavy template units using MAKEOPTS.
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
		# Filter before Go captures unsupported ROCm flags in CGO_*. bug #963401
		strip-unsupported-flags
		export CXXFLAGS="$(test-flags-HIPCXX "${CXXFLAGS}")"
	fi

	# Also unpacks prestaged llama.cpp and Go dependencies into GOMODCACHE.
	go-module_src_unpack
}

src_prepare() {
	cmake_src_prepare

	# Patch missing <fstream> for GCC 17 only when the pinned llama.cpp lacks
	# upstream's fix. b10760 includes it. verified 2026-09-04
	pushd "${LLAMACPP_S}" >/dev/null || die
	if ! grep -q '#include <fstream>' common/common.h; then
		eapply "${FILESDIR}/${PN}-gcc17-fstream.patch"
	fi
	popd >/dev/null || die

	# Do not apply llama/compat here: the symlinked ExternalProject retains
	# upstream's apply-patch step, including model architecture patches.

	# Match runtime lookup to Gentoo's multilib install path.
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
		# Upstream nested builds otherwise ignore MAKEOPTS and use all cores;
		# propagate the job cap to avoid GPU-template OOMs.
		-DOLLAMA_BUILD_PARALLEL="$(makeopts_jobs)"
	)

	if use rocm; then
		# Select the user-arch preset and forward targets to ggml-hip.
		mycmakeargs+=( -DAMDGPU_TARGETS="$(get_amdgpu_flags)" )
	fi

	cmake_src_configure

	# Supply the prestaged tree where the patched ExternalProject expects it.
	rm -rf "${BUILD_DIR}/_deps/llama_cpp-src" || die
	ln -s "${LLAMACPP_S}" "${BUILD_DIR}/_deps/llama_cpp-src" || die
}

src_compile() {
	if use cuda; then
		# The nested CUDA build reads CUDAHOSTCXX here; select a supported GCC and
		# grant its device probes during compilation.
		local -x CUDAHOSTCXX
		CUDAHOSTCXX="$(cuda_gccdir)/g++"
		cuda_add_sandbox -w
		addpredict "/dev/char/"
	fi

	if use rocm; then
		# Nested CMake requires ROCm Clang, not the hipcc wrapper. Keep GCC for CPU
		# and cgo, and preseed targets to avoid sandboxed GPU enumeration.
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
	# Avoid cmake_src_install: it rebuilds BUILD_ALWAYS subprojects and installs
	# duplicate payloads under D. Run only the top-level install script.
	DESTDIR="${D}" cmake --install "${BUILD_DIR}" || die

	if use openrc; then
		newinitd "${FILESDIR}"/ollama.init "${PN}"
		newconfd "${FILESDIR}"/ollama.confd "${PN}"
	fi
	if use systemd; then
		systemd_dounit "${FILESDIR}"/ollama.service
	fi
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
