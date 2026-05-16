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
	https://files.pythonhosted.org/packages/f5/50/e93be26781b168f3c99fb1f26b4f1aaf11f57a04b4e48569f33a7cce21a8/${CORE_WHEEL}
	python_single_target_python3_12? (
		https://files.pythonhosted.org/packages/19/b5/43994e3f7b92cf046be2dfbf409e59495827612ab625b9d8329b68b8a844/sherpa_onnx-${PV}-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
	)
	python_single_target_python3_13? (
		https://files.pythonhosted.org/packages/f9/a1/2a35324c4c6cdccdfa1b23cb2a9d7263dddfba30c57a7d46bab8fd19160d/sherpa_onnx-${PV}-cp313-cp313-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
	)
	python_single_target_python3_14? (
		https://files.pythonhosted.org/packages/4e/c6/6e2675a0f1eb5de084bd430c732ac399684af9f90a51b46a39987b84d762/sherpa_onnx-${PV}-cp314-cp314-manylinux2014_x86_64.manylinux_2_17_x86_64.whl
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
