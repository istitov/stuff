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

# Install the ABI-specific bindings and ABI-independent core wheel together;
# $ORIGIN lookup requires their libraries in one sherpa_onnx tree.
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
		https://files.pythonhosted.org/packages/ac/b1/74a7a5eea77de5d9c2d5a508b27e6d1cc16ff188c31554d014c191f883d2/${AMD64_CORE_WHEEL}
		python_single_target_python3_12? ( https://files.pythonhosted.org/packages/91/2f/7a7d02059f0646255b89a3c23b094f28c86b1cdd2af009738cfba3a6da9e/sherpa_onnx-${PV}-cp312-cp312-${AMD64_WHEEL_TAIL} )
		python_single_target_python3_13? ( https://files.pythonhosted.org/packages/42/6a/cb2c7b75ef120ea9f51e78efefafaffba334c9505abd91eac47cb4e630e8/sherpa_onnx-${PV}-cp313-cp313-${AMD64_WHEEL_TAIL} )
		python_single_target_python3_14? ( https://files.pythonhosted.org/packages/32/86/f08a5a0b265f5e1d2c05f87e0ae899f3c74fdd5d4baec624bb5579af0715/sherpa_onnx-${PV}-cp314-cp314-${AMD64_WHEEL_TAIL} )
	)
	arm64? (
		https://files.pythonhosted.org/packages/78/df/06d3cfa2f91558aa2d86a807ff70b3a448903697e44151634eef84225d54/${ARM64_CORE_WHEEL}
		python_single_target_python3_12? ( https://files.pythonhosted.org/packages/b7/73/a29e0b78bc71f447469adcd633873ab045d5fad1c854ce790061ed6efcb9/sherpa_onnx-${PV}-cp312-cp312-${ARM64_WHEEL_TAIL} )
		python_single_target_python3_13? ( https://files.pythonhosted.org/packages/c6/b9/45cfb448a05709cb51c3f224df1b690a695a98d470e8a1f2bf1ac345eb68/sherpa_onnx-${PV}-cp313-cp313-${ARM64_WHEEL_TAIL} )
		python_single_target_python3_14? ( https://files.pythonhosted.org/packages/a3/b9/8b3c730150100008ad0eb113996173b02e91d29cdbe22cec540eec3b0ffb/sherpa_onnx-${PV}-cp314-cp314-${ARM64_WHEEL_TAIL} )
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="
	usr/lib/python3.*/site-packages/sherpa_onnx/lib/*
	usr/lib/python3.*/site-packages/sherpa_onnx.libs/*
"

# Require lazy-imported click so the CLI works. Block the colliding source
# package.
RDEPEND="
	!sci-ml/sherpa-onnx
	$(python_gen_cond_dep '
		dev-python/click[${PYTHON_USEDEP}]
	')
"

BDEPEND+="
	$(python_gen_cond_dep '
		dev-python/installer[${PYTHON_USEDEP}]
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
