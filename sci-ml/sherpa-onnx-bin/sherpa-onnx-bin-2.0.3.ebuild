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
		https://files.pythonhosted.org/packages/44/a8/339ae6e5edd700c0e3a5a5dbfa64136d186bf1c1c795295fab0df2b57bf7/${AMD64_CORE_WHEEL}
		python_single_target_python3_12? ( https://files.pythonhosted.org/packages/a7/7b/38944c6f90b39e72975617a81155622791357e0721f1d82affe8b59e0f02/sherpa_onnx-${PV}-cp312-cp312-${AMD64_WHEEL_TAIL} )
		python_single_target_python3_13? ( https://files.pythonhosted.org/packages/e6/6c/635eaceef707b5c085d47e2cf86f639a84c7b94935bbf27e4b2666d388de/sherpa_onnx-${PV}-cp313-cp313-${AMD64_WHEEL_TAIL} )
		python_single_target_python3_14? ( https://files.pythonhosted.org/packages/14/cd/3a3a95afdfea1cc674f9ea5b67f3319f88d4559cc489490dbff75c2a8cc3/sherpa_onnx-${PV}-cp314-cp314-${AMD64_WHEEL_TAIL} )
	)
	arm64? (
		https://files.pythonhosted.org/packages/c0/20/cff1fd963b27df73e7ebb7c40a5640d6932361b9223df6de72dffa637f44/${ARM64_CORE_WHEEL}
		python_single_target_python3_12? ( https://files.pythonhosted.org/packages/3c/42/1043dc208f5bf1dd1783d92947da8ae455fd41174748483532b259bc27a7/sherpa_onnx-${PV}-cp312-cp312-${ARM64_WHEEL_TAIL} )
		python_single_target_python3_13? ( https://files.pythonhosted.org/packages/47/9e/7db81e728ac053ec859844b0afab28b12d7b76ae4bc810d0472cf3736e94/sherpa_onnx-${PV}-cp313-cp313-${ARM64_WHEEL_TAIL} )
		python_single_target_python3_14? ( https://files.pythonhosted.org/packages/65/71/b25b66d0a7d25c388df77caf711605aa61403f902b1bef4d061c59f6d462/sherpa_onnx-${PV}-cp314-cp314-${ARM64_WHEEL_TAIL} )
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
