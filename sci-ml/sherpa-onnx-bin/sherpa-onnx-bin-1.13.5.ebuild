# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Speech-to-text, TTS, speaker diarization etc. using onnxruntime (binary wheels)"
HOMEPAGE="
	https://k2-fsa.github.io/sherpa/onnx/
	https://github.com/k2-fsa/sherpa-onnx
	https://pypi.org/project/sherpa-onnx/
"

# Upstream ships two co-installable wheels: sherpa-onnx-core (the C++
# shared libs, Python-version-agnostic) + sherpa-onnx (the Python
# bindings, per-CPython-ABI). The per-Python wheel's _sherpa_onnx.so
# has RPATH "$ORIGIN" and dlopen()s libonnxruntime.so from the same
# directory; sherpa-onnx-core drops it there. Both must install into
# the same sherpa_onnx/ tree.
CORE_WHEEL="sherpa_onnx_core-${PV}-py3-none-manylinux2014_x86_64.whl"
SRC_URI="
	https://files.pythonhosted.org/packages/8f/61/2cf3aee64c280c830ca4fa25584eb87f8acf04787152744a29d576323977/${CORE_WHEEL}
	python_single_target_python3_12? (
		https://files.pythonhosted.org/packages/e1/6e/621e7c30dd1eb399f03905cbf13b50dc49fdceb90775b68a995b0773ba0d/sherpa_onnx-${PV}-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
	)
	python_single_target_python3_13? (
		https://files.pythonhosted.org/packages/9a/3b/817cdb5770f8beafd22a04a8eda0c8253a6d07a518a09ce982d6e4152e3c/sherpa_onnx-${PV}-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
	)
	python_single_target_python3_14? (
		https://files.pythonhosted.org/packages/45/91/56a439945713a5cf49080a833fbd0953936fcd50c651c17afe64478c9922/sherpa_onnx-${PV}-cp314-cp314-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"

# click is lazy-imported in sherpa_onnx.cli with an explicit prompt to
# install it if missing; we make it a hard runtime dep so the
# sherpa-onnx-cli entry point works out of the box.
#
# Blocks the source ebuild: both ship sherpa_onnx into site-packages,
# they'd collide. Pick one or the other.
RDEPEND="
	!sci-ml/sherpa-onnx
	$(python_gen_cond_dep '
		dev-python/click[${PYTHON_USEDEP}]
	')
"

src_unpack() {
	mkdir -p "${S}/wheels" || die
	cp "${DISTDIR}/${CORE_WHEEL}" "${S}/wheels/" || die
	local impl=${EPYTHON#python}
	impl=${impl/./}
	local py_wheel="sherpa_onnx-${PV}-cp${impl}-cp${impl}-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
	cp "${DISTDIR}/${py_wheel}" "${S}/wheels/" || die
}

src_install() {
	python_setup
	local wheel
	for wheel in "${S}"/wheels/*.whl; do
		${EPYTHON} -m installer --destdir="${D}" "${wheel}" || die
	done
}

pkg_postinst() {
	elog ""
	elog "sherpa-onnx ships no model files — each speech task needs its own"
	elog "ONNX model bundle.  Browse the catalog at"
	elog "  https://k2-fsa.github.io/sherpa/onnx/pretrained_models/"
	elog ""
	elog "For speaker diarization specifically, the maintained ONNX"
	elog "conversion of pyannote-segmentation-3.0 + 3D-Speaker embeddings"
	elog "lives at"
	elog "  https://huggingface.co/csukuangfj/sherpa-onnx-pyannote-segmentation-3-0"
	elog "These are ungated (no HuggingFace token or model-card acceptance"
	elog "required), unlike sci-ml/pyannote-audio's runtime models."
	elog ""
}
