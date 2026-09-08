# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
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
AMD64_WHEEL_TAIL="manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
ARM64_WHEEL_TAIL="manylinux2014_aarch64.manylinux_2_17_aarch64.whl"
AMD64_CORE_WHEEL="sherpa_onnx_core-${PV}-py3-none-manylinux2014_x86_64.whl"
ARM64_CORE_WHEEL="sherpa_onnx_core-${PV}-py3-none-manylinux2014_aarch64.whl"

case ${ARCH} in
	amd64)
		WHEEL_TAIL=${AMD64_WHEEL_TAIL}
		CORE_WHEEL=${AMD64_CORE_WHEEL}
		;;
	arm64)
		WHEEL_TAIL=${ARM64_WHEEL_TAIL}
		CORE_WHEEL=${ARM64_CORE_WHEEL}
		;;
esac
SRC_URI="
	amd64? (
		https://files.pythonhosted.org/packages/fa/0a/6f64568ebb230b200c30c465eb002113944705fa36c734838ea46f2e1802/${AMD64_CORE_WHEEL}
		python_single_target_python3_12? ( https://files.pythonhosted.org/packages/75/8c/3a4bcdc71f9ea22b9ce77e2e562324a010be96b855a4cd4a73f83dc6b646/sherpa_onnx-${PV}-cp312-cp312-${AMD64_WHEEL_TAIL} )
		python_single_target_python3_13? ( https://files.pythonhosted.org/packages/fe/3e/c3a60cf13301363210e7a0cc72a901ae6a56e313e1d912df0017e24e6e79/sherpa_onnx-${PV}-cp313-cp313-${AMD64_WHEEL_TAIL} )
		python_single_target_python3_14? ( https://files.pythonhosted.org/packages/bd/92/638cb914a924d9039270113c8ecdd419a82a56072141bea85d8a88433ade/sherpa_onnx-${PV}-cp314-cp314-${AMD64_WHEEL_TAIL} )
	)
	arm64? (
		https://files.pythonhosted.org/packages/58/ab/ab279cf4eb6d4aa4b5f703d4e8233365c3acee304b963a09d4cb71601324/${ARM64_CORE_WHEEL}
		python_single_target_python3_12? ( https://files.pythonhosted.org/packages/da/71/9fe597931cfcff8c42e4631156bf5a4efb90d6c635f8dd09f1d815f221eb/sherpa_onnx-${PV}-cp312-cp312-${ARM64_WHEEL_TAIL} )
		python_single_target_python3_13? ( https://files.pythonhosted.org/packages/bf/f3/5d50f5e675d972c39d908f82b554e6e1734c2d165e6573b8b92e7b0f3aaa/sherpa_onnx-${PV}-cp313-cp313-${ARM64_WHEEL_TAIL} )
		python_single_target_python3_14? ( https://files.pythonhosted.org/packages/f5/a0/05b594030df8c52e9a89e1615e3b6d59f99db1c884a33f6d5d2782045650/sherpa_onnx-${PV}-cp314-cp314-${ARM64_WHEEL_TAIL} )
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

QA_PREBUILT="
	usr/lib/python3.*/site-packages/sherpa_onnx/lib/*
	usr/lib/python3.*/site-packages/sherpa_onnx.libs/*
"

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
	local py_wheel="sherpa_onnx-${PV}-cp${impl}-cp${impl}-${WHEEL_TAIL}"
	cp "${DISTDIR}/${py_wheel}" "${S}/wheels/" || die
}

src_install() {
	python_setup
	local wheel
	for wheel in "${S}"/wheels/*.whl; do
		${EPYTHON} -m installer --destdir="${D}" "${wheel}" || die
	done
	python_optimize
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
