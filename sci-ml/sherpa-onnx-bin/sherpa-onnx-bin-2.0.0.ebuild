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
		https://files.pythonhosted.org/packages/ae/66/e234ca87aa77b6e834bafc61c772539120a5095bd38ad949957b9fbbe9ba/${AMD64_CORE_WHEEL}
		python_single_target_python3_12? ( https://files.pythonhosted.org/packages/85/ba/1ba4d5a15d7e676ea32c4fbdfbb09ff395b40d908ac791900ecd4e7932f0/sherpa_onnx-${PV}-cp312-cp312-${AMD64_WHEEL_TAIL} )
		python_single_target_python3_13? ( https://files.pythonhosted.org/packages/fd/c2/1ef88dc547540a97228ffb251c92be4376a7c1388f1745583fcca5274189/sherpa_onnx-${PV}-cp313-cp313-${AMD64_WHEEL_TAIL} )
		python_single_target_python3_14? ( https://files.pythonhosted.org/packages/59/de/d5c7409b14c9471880e397783b82caca7d1797d6fd2e06368576bf6b01dc/sherpa_onnx-${PV}-cp314-cp314-${AMD64_WHEEL_TAIL} )
	)
	arm64? (
		https://files.pythonhosted.org/packages/83/2b/0f2fea18f9551471b0e12e31a815a06dd20e1950b57ef68397dda8332225/${ARM64_CORE_WHEEL}
		python_single_target_python3_12? ( https://files.pythonhosted.org/packages/f5/67/61b96b39efb0f756591fb4bbe9c76832789dfe5ae442b69fa0b988176d53/sherpa_onnx-${PV}-cp312-cp312-${ARM64_WHEEL_TAIL} )
		python_single_target_python3_13? ( https://files.pythonhosted.org/packages/35/94/3487a5ed63c5f86b650198581f8966540727805ea9cc4584c464af065770/sherpa_onnx-${PV}-cp313-cp313-${ARM64_WHEEL_TAIL} )
		python_single_target_python3_14? ( https://files.pythonhosted.org/packages/45/4f/e2be6615088830169bffa9583e1d275538c0b403980c9058929f1e01ae20/sherpa_onnx-${PV}-cp314-cp314-${ARM64_WHEEL_TAIL} )
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
