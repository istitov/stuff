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
		https://files.pythonhosted.org/packages/b6/ca/e27c1fb5c54b181d4a5450f3d5c789d9da02eb42dc9b20cfdab5dda4c864/${AMD64_CORE_WHEEL}
		python_single_target_python3_12? ( https://files.pythonhosted.org/packages/13/78/2f712b7408ddbb64614c20388912414705b728516224e737b63f2adec94a/sherpa_onnx-${PV}-cp312-cp312-${AMD64_WHEEL_TAIL} )
		python_single_target_python3_13? ( https://files.pythonhosted.org/packages/8f/eb/b77acde02d9eee359436ade9239d9ade4351b09fbe85387a293f341c19ed/sherpa_onnx-${PV}-cp313-cp313-${AMD64_WHEEL_TAIL} )
		python_single_target_python3_14? ( https://files.pythonhosted.org/packages/2d/e2/b1af63c1f6a9e0025cbc9aa3b1814ba97ede63db0ad9f297bb9f268fdfc2/sherpa_onnx-${PV}-cp314-cp314-${AMD64_WHEEL_TAIL} )
	)
	arm64? (
		https://files.pythonhosted.org/packages/9c/72/02227b14cd3fb3d504a8814ad144ed321a53331948c893821e02f4abb1d7/${ARM64_CORE_WHEEL}
		python_single_target_python3_12? ( https://files.pythonhosted.org/packages/1f/5f/22e1571146b2c0b581657562d5919b69da13ed93dc70049f42d45fe9e84c/sherpa_onnx-${PV}-cp312-cp312-${ARM64_WHEEL_TAIL} )
		python_single_target_python3_13? ( https://files.pythonhosted.org/packages/13/e3/115476caa9f80cd5f55e4e7b777a6c2d01a133d10f8fae574ba869fc48c3/sherpa_onnx-${PV}-cp313-cp313-${ARM64_WHEEL_TAIL} )
		python_single_target_python3_14? ( https://files.pythonhosted.org/packages/4f/9a/51821829b5735b3d7ce607992a62fe93d5f7215cda324c11191c77d49b9b/sherpa_onnx-${PV}-cp314-cp314-${ARM64_WHEEL_TAIL} )
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
