# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_12 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

MY_PN=${PN%-bin}
# Portage PV 0.12_p1 <-> PyPI 0.12.post1 (the wheel filename uses the latter).
MY_PV="${PV/_p/.post}"
MY_WHEEL="${MY_PN//-/_}-${MY_PV}-py3-none-any.whl"

DESCRIPTION="AMD's quantization toolkit for ML model optimization (binary wheel)"
HOMEPAGE="
	https://quark.docs.amd.com
	https://github.com/amd/quark
	https://pypi.org/project/amd-quark/
"
SRC_URI="
	https://files.pythonhosted.org/packages/f5/39/6cd824701dbe02d9bba809cab86a821f9b3b2bed071623b19b102c0659c2/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"

# Wheel-only on PyPI; upstream pins requires_python = "<3.14,>=3.11".
# Optional AMD-quark quantization tool — vllm's rocm path can use it but
# does not depend on it, and nothing else in the tree RDEPENDs on it.
#
# onnx floor relaxed: upstream 0.12 requires onnx>=1.21.0,<=1.22.0, but
# ::gentoo tops out at onnx-1.20.1, so RDEPEND floors at 1.20.1 (the
# highest available; the `>=` self-heals to upstream's range once
# onnx-1.21+ lands). Safe here because the ONNX code paths are already
# non-functional: onnxscript and onnxslim (install-time deps of the
# wheel) are unpackaged in ::gentoo + ::guru, so anything touching ONNX
# export ImportErrors regardless — the PyTorch-only quantization paths
# this tool is used for don't import onnx. (Upstream 0.12 also dropped
# the old numpy<=2.1.3 cap → numpy>=2.0, which our unpinned numpy meets;
# new psutil dep added.) verified 2026-07-18
RDEPEND="
	sci-ml/evaluate[${PYTHON_SINGLE_USEDEP}]
	app-alternatives/ninja
	$(python_gen_cond_dep '
		dev-python/joblib[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		>=sci-ml/onnx-1.20.1[${PYTHON_USEDEP}]
		dev-python/pandas[${PYTHON_USEDEP}]
		dev-python/plotly[${PYTHON_USEDEP}]
		dev-python/protobuf[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		dev-python/pydantic[${PYTHON_USEDEP}]
		dev-python/rich[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		sci-ml/sentencepiece[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/zstandard[${PYTHON_USEDEP}]
	')
"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

src_install() {
	python_setup
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die
}
