# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit cmake python-single-r1

DESCRIPTION="Speech-to-text, TTS, speaker diarization etc. using onnxruntime"
HOMEPAGE="
	https://k2-fsa.github.io/sherpa/onnx/
	https://github.com/k2-fsa/sherpa-onnx
"

# Upstream's CMake build vendors every dep via FetchContent with a
# `possible_file_locations` fallback that includes ${CMAKE_SOURCE_DIR}/.
# Pre-fetch all the tarballs and drop them into ${S} during src_unpack;
# no network needed during build. Renames keep the filenames matching
# what the cmake modules look for. Sub-deps (kissfft via
# kaldi-native-fbank, kaldifst via kaldi-decoder) use the same global
# CMAKE_SOURCE_DIR fallback so the same staging directory works.
SRC_URI="
	https://github.com/k2-fsa/sherpa-onnx/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
	https://gitlab.com/libeigen/eigen/-/archive/5.0.1/eigen-5.0.1.tar.gz
	https://github.com/likle/cargs/archive/refs/tags/v1.0.3.tar.gz
		-> cargs-1.0.3.tar.gz
	https://github.com/csukuangfj/hclust-cpp/archive/refs/tags/2026-02-25.tar.gz
		-> hclust-cpp-2026-02-25.tar.gz
	https://github.com/nlohmann/json/archive/refs/tags/v3.12.0.tar.gz
		-> json-3.12.0.tar.gz
	https://github.com/k2-fsa/kaldi-decoder/archive/refs/tags/v0.3.0.tar.gz
		-> kaldi-decoder-0.3.0.tar.gz
	https://github.com/csukuangfj/kaldi-native-fbank/archive/refs/tags/v1.22.3.tar.gz
		-> kaldi-native-fbank-1.22.3.tar.gz
	https://github.com/csukuangfj/openfst/archive/refs/tags/v1.8.5-2026-04-11.tar.gz
		-> openfst-1.8.5-2026-04-11.tar.gz
	https://github.com/pkufool/simple-sentencepiece/archive/refs/tags/v0.7.tar.gz
		-> simple-sentencepiece-0.7.tar.gz
	https://github.com/mborgerding/kissfft/archive/febd4caeed32e33ad8b2e0bb5ea77542c40f18ec.zip
		-> kissfft-febd4caeed32e33ad8b2e0bb5ea77542c40f18ec.zip
	https://github.com/k2-fsa/kaldifst/archive/refs/tags/v1.8.0.tar.gz
		-> kaldifst-1.8.0.tar.gz
	portaudio? (
		http://files.portaudio.com/archives/pa_stable_v190700_20210406.tgz
	)
	python? (
		https://github.com/pybind/pybind11/archive/refs/tags/v3.0.0.tar.gz
			-> pybind11-3.0.0.tar.gz
	)
	tts? (
		https://github.com/csukuangfj/espeak-ng/archive/f6fed6c58b5e0998b8e68c6610125e2d07d595a7.zip
			-> espeak-ng-f6fed6c58b5e0998b8e68c6610125e2d07d595a7.zip
		https://github.com/csukuangfj/piper-phonemize/archive/78a788e0b719013401572d70fef372e77bff8e43.zip
			-> piper-phonemize-78a788e0b719013401572d70fef372e77bff8e43.zip
	)
	websocket? (
		https://github.com/chriskohlhoff/asio/archive/refs/tags/asio-1-24-0.tar.gz
			-> asio-asio-1-24-0.tar.gz
		https://github.com/zaphoyd/websocketpp/archive/b9aeec6eaf3d5610503439b4fae3581d9aff08e8.zip
			-> websocketpp-b9aeec6eaf3d5610503439b4fae3581d9aff08e8.zip
	)
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda +portaudio +python +tts +websocket"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

# sherpa-onnx vendors and statically links portaudio (PA_BUILD_STATIC=ON
# in cmake/portaudio.cmake), so the USE=portaudio flag adds no system
# dep — just toggles whether the mic-recording demo CLIs get built.
# media-libs/alsa-lib *is* needed: a handful of *-alsa demo binaries
# link against -lasound regardless of USE flags.
#
# Blocks the -bin ebuild: both ship sherpa_onnx into site-packages
# (under USE=python, which is the default here), they'd collide.
RDEPEND="
	!sci-ml/sherpa-onnx-bin
	sci-libs/onnxruntime:=
	media-libs/alsa-lib
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	python? (
		${PYTHON_DEPS}
	)
"
DEPEND="${RDEPEND}"
# app-arch/unzip is used by CMake's FetchContent at configure time to
# extract the .zip-archived vendored deps (kissfft, websocketpp,
# piper-phonemize, espeak-ng). Upstream ships these as .zip rather than
# .tar.gz on github even though tarball mirrors exist — keeping .zip to
# match the cmake possible_file_locations fallback filenames.
BDEPEND="
	app-arch/unzip
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-python/pybind11[${PYTHON_USEDEP}]
		')
	)
"

# /opt/sherpa-onnx/lib contains a pile of vendored .a + private .so
# files (cargs, kaldi-*, kissfft, sherpa-onnx-fst, ...) that are
# prebuilt and don't need stripping or world-readable scanning.
QA_PREBUILT="opt/sherpa-onnx/lib/*"

src_unpack() {
	# Only unpack the main sherpa-onnx tarball; the vendored dep
	# tarballs stay archived and get copied into ${S} where the cmake
	# modules' possible_file_locations check picks them up.
	unpack "${P}.gh.tar.gz"

	# A is a space-separated string of distfile names (not an array).
	local f
	for f in ${A}; do
		[[ ${f} == "${P}.gh.tar.gz" ]] && continue
		cp -- "${DISTDIR}/${f}" "${S}/" || die
	done
}

src_configure() {
	use python && python_setup

	local mycmakeargs=(
		# Self-contained install under /opt to keep the ~23 CLI tools
		# and vendored helper libs (cargs etc.) out of /usr/{bin,lib}.
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/opt/sherpa-onnx"
		-DBUILD_SHARED_LIBS=ON
		-DSHERPA_ONNX_USE_PRE_INSTALLED_ONNXRUNTIME_IF_AVAILABLE=ON
		-DSHERPA_ONNX_ENABLE_C_API=ON
		-DSHERPA_ONNX_ENABLE_BINARY=ON
		-DSHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION=ON
		-DSHERPA_ONNX_LINK_LIBSTDCPP_STATICALLY=OFF
		-DSHERPA_ONNX_ENABLE_TESTS=OFF
		-DSHERPA_ONNX_ENABLE_PYTHON=$(usex python)
		-DSHERPA_ONNX_ENABLE_PORTAUDIO=$(usex portaudio)
		-DSHERPA_ONNX_ENABLE_WEBSOCKET=$(usex websocket)
		-DSHERPA_ONNX_ENABLE_TTS=$(usex tts)
		-DSHERPA_ONNX_ENABLE_GPU=$(usex cuda)
		-DSHERPA_ONNX_ENABLE_JNI=OFF
		-DSHERPA_ONNX_ENABLE_WASM=OFF
	)

	if use cuda; then
		# CUDA 13.x nvcc on this host rejects gcc>15. See
		# feedback_cuda_13_host_compiler_gcc_15 — pinned via CUDAHOSTCXX.
		export CUDAHOSTCXX="/usr/bin/g++-15"
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Expose /opt/sherpa-onnx/bin on PATH + lib on LDPATH so the
	# unprefixed `sherpa-onnx` command works and the libs resolve
	# transparently.
	newenvd - 99sherpa-onnx <<-EOF
		PATH="${EPREFIX}/opt/sherpa-onnx/bin"
		LDPATH="${EPREFIX}/opt/sherpa-onnx/lib"
	EOF

	if use python; then
		# Python bindings still need to live under site-packages so
		# `import sherpa_onnx` works without PYTHONPATH gymnastics. The
		# pybind11 module dlopens libsherpa-onnx-c-api.so etc. — those
		# are reached via LDPATH from the env.d file above.
		local opt_pylib="${ED}/opt/sherpa-onnx/lib"
		local pylib_dst_rel="$(python_get_sitedir)/sherpa_onnx/lib"

		dodir "${pylib_dst_rel}"
		local so
		for so in "${opt_pylib}"/_sherpa_onnx*.so; do
			[[ -e ${so} ]] || continue
			mv "${so}" "${ED}/${pylib_dst_rel}/" || die
		done

		# Python source files
		python_moduleinto sherpa_onnx
		python_domodule "${S}/sherpa-onnx/python/sherpa_onnx"/*.py
	fi
}

pkg_postinst() {
	elog ""
	elog "sherpa-onnx ${PV} installed to /opt/sherpa-onnx."
	elog "After re-sourcing /etc/profile (new shell or 'source /etc/profile')"
	elog "the binaries on PATH:"
	elog "  sherpa-onnx --help                    # generic ASR/runtime entry"
	elog "  sherpa-onnx-offline-speaker-diarization --help"
	elog "  sherpa-onnx-vad --help                # voice activity detection"
	elog "  ... (~23 task-specific tools under /opt/sherpa-onnx/bin/)"
	elog ""
	elog "Model files are not bundled — see"
	elog "  https://k2-fsa.github.io/sherpa/onnx/pretrained_models/"
	elog "For speaker diarization specifically, the ONNX-converted pyannote"
	elog "models + 3D-Speaker embeddings live at"
	elog "  https://huggingface.co/csukuangfj/sherpa-onnx-pyannote-segmentation-3-0"
	elog "(ungated, no HuggingFace token required, unlike sci-ml/pyannote-audio)."
	elog ""
}
