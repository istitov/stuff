# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-single-r1 toolchain-funcs wrapper

DESCRIPTION="All-in-one local AI server (LLM, image, speech, TTS) on ggml/llama.cpp"
HOMEPAGE="https://github.com/LostRuins/koboldcpp"
SRC_URI="https://github.com/LostRuins/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/${PN}-${PV}"

# AGPL-3.0 covers the koboldcpp code + the embedded KoboldAI Lite UI; the
# bundled ggml / llama.cpp / stable-diffusion.cpp / TTS.cpp libraries are MIT
# (MIT_LICENSE_GGML_SDCPP_LLAMACPP_ONLY.md).
LICENSE="AGPL-3+ MIT"
SLOT="0"
KEYWORDS="~amd64"

# Vulkan is upstream's official GPU acceleration for both AMD and NVIDIA.
# CUDA (koboldcpp_cublas) and ROCm/hipBLAS (an unofficial upstream fork) are
# intentionally not wired here yet: neither has been build-verified for this
# overlay (ROCm's Makefile GPU_TARGETS handling needs work). Prefer Vulkan.
IUSE="+vulkan"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# koboldcpp.py dlopen()s the compiled backend .so files, and the image/speech/
# TTS features all live in the C++ libraries -- but the launcher is NOT pure
# stdlib, as this comment previously claimed. Audited 2026-08-29 against the
# 1.120 tree:
#
#   jinja2       - format_jinja() imports jinja2.ext/jinja2.sandbox for chat
#                  templates. The whole function body sits in a try:, so it
#                  degrades rather than crashing, but chat-template handling
#                  is a normal runtime path. Declared.
#   psutil       - imported inside try: at two spots (process priority, RAM
#                  reporting). Genuinely optional; left as an optfeature.
#   customtkinter- the launcher GUI. NOT PACKAGED in ::gentoo or ::stuff, so
#                  it cannot be declared; see the CLI-only note below.
#
# Upstream's requirements.txt is repo-wide, not the launcher's dep list: it
# also pins numpy/transformers/sentencepiece/gguf/protobuf for the
# convert_hf_to_gguf.py conversion scripts, none of which koboldcpp.py
# imports (verified: zero import sites for each).
RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/jinja2[${PYTHON_USEDEP}]
	')
	vulkan? ( media-libs/vulkan-loader )
"
DEPEND="
	${RDEPEND}
	vulkan? ( dev-util/vulkan-headers )
"
BDEPEND="
	${PYTHON_DEPS}
	vulkan? ( media-libs/shaderc )
"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default
	# The release build strips the .so at link time (-s); leave stripping
	# to Portage so splitdebug/nostrip are honored and the pre-stripped QA
	# notice is silenced. Keep -DNDEBUG (it no-ops assert()).
	sed -i -e 's/-DNDEBUG -s/-DNDEBUG/g' Makefile || die

	# Drop the bundled prebuilt shader compilers so the Vulkan build uses
	# the system media-libs/shaderc glslc (LLAMA_USE_BUNDLED_GLSLC= empty
	# in src_compile). Their absence also removes the only executed blob.
	rm -f glslc-linux glslc.exe || die
}

src_compile() {
	tc-export CC CXX

	local targets=( koboldcpp_default )
	local makeargs=(
		# Empty (not 0) so the Makefile's `[ -n "$LLAMA_USE_BUNDLED_GLSLC" ]`
		# test is false and it selects the system glslc (media-libs/shaderc)
		# for Vulkan shader generation instead of the bundled binary.
		LLAMA_USE_BUNDLED_GLSLC=
	)

	if use vulkan; then
		targets+=( koboldcpp_vulkan )
		makeargs+=( LLAMA_VULKAN=1 )
	fi

	emake "${makeargs[@]}" "${targets[@]}"
}

src_install() {
	local dest="/usr/share/${PN}"

	insinto "${dest}"
	doins koboldcpp.py
	# The compiled backends (koboldcpp_default.so and, with USE=vulkan,
	# koboldcpp_vulkan.so) sit beside the launcher, which locates them via
	# os.path.dirname(__file__).
	doins koboldcpp_*.so
	# Embedded web UI (KoboldAI Lite), API docs, SD/TTS resources and the
	# chat-format adapters, read from <script_dir>/embd_res and kcpp_adapters.
	doins -r embd_res kcpp_adapters

	python_fix_shebang "${ED}${dest}/koboldcpp.py"

	# Thin launcher on PATH.
	make_wrapper "${PN}" "${EPYTHON} ${EPREFIX}${dest}/koboldcpp.py"

	dodoc README.md
}

pkg_postinst() {
	elog "koboldcpp installed to ${EROOT}/usr/share/${PN}; run it with:"
	elog "    koboldcpp --model /path/to/model.gguf"
	elog
	elog "This package is CLI-only. Run with no --model and upstream tries to"
	elog "open its customtkinter launcher GUI, which is not packaged for Gentoo;"
	elog "koboldcpp catches that, prints \"customtkinter python module required\""
	elog "and exits 2. Always pass --model (or --config)."
	elog
	if use vulkan; then
		elog "Vulkan (the official AMD/NVIDIA GPU path) is available; add"
		elog "    --usevulkan"
		elog "to offload to the GPU."
	fi
	elog "Models are NOT bundled; download a .gguf yourself."
}
