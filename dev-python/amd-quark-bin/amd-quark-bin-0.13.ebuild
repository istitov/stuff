# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
# Upstream caps Python below 3.14; ignore pkgcheck's wheel-based 3.14 suggestion.
# verified 2026-09-28
PYTHON_COMPAT=( python3_{12..13} )
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
	https://files.pythonhosted.org/packages/c7/e7/d8d6fd4676319426431bdcd573990883b7e8944779d485cd449100788714/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"

# Wheel-only optional quantizer used by vLLM's ROCm path.
# Upstream requires ONNX 1.21-1.22, but ::gentoo has 1.20.1. ONNX paths are
# already unavailable without unpackaged onnxscript/onnxslim; the used PyTorch
# paths do not import them. Raise the floor when ONNX lands. # verified 2026-09-28
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
