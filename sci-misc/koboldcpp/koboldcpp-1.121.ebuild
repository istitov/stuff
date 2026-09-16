# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-single-r1 toolchain-funcs wrapper

DESCRIPTION="All-in-one local AI server (LLM, image, speech, TTS) on ggml/llama.cpp"
HOMEPAGE="https://github.com/LostRuins/koboldcpp"
SRC_URI="https://github.com/LostRuins/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/${PN}-${PV}"

# Koboldcpp and its UI are AGPL-3+; bundled inference libraries are MIT.
LICENSE="AGPL-3+ MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Vulkan is the only build-verified GPU backend here; CUDA and the unofficial
# ROCm path remain unwired, with ROCm GPU_TARGETS still unresolved.
IUSE="+vulkan"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# The launcher dlopens C++ backends but uses Jinja2 for chat templates. psutil is
# optional; customtkinter is unpackaged, so this remains CLI-only. Repo-wide
# requirements for conversion scripts are not launcher dependencies.
# verified against 1.120 on 2026-08-29
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
	# Leave stripping to Portage for splitdebug/nostrip; retain -DNDEBUG.
	sed -i -e 's/-DNDEBUG -s/-DNDEBUG/g' Makefile || die

	# Drop bundled shader compilers and select system glslc below.
	rm -f glslc-linux glslc.exe || die
}

src_compile() {
	tc-export CC CXX

	local targets=( koboldcpp_default )
	local makeargs=(
		# Must be empty, not 0: the Makefile tests string length.
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
	# The launcher finds backends beside its own file.
	doins koboldcpp_*.so
	# Runtime UI, model resources, and chat adapters.
	doins -r embd_res kcpp_adapters

	python_fix_shebang "${ED}${dest}/koboldcpp.py"

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
