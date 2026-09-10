# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_12 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

MY_PN=${PN%-bin}
MY_WHEEL="${MY_PN//-/_}-${PV}-py3-none-any.whl"

DESCRIPTION="AMD's quantization toolkit for ML model optimization (binary wheel)"
HOMEPAGE="
	https://quark.docs.amd.com
	https://github.com/amd/quark
	https://pypi.org/project/amd-quark/
"
SRC_URI="
	https://files.pythonhosted.org/packages/95/59/9191965320615f58d582eb805661484f741dac97d6e10c7989f051a6aa7e/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64"

# Binary-only vLLM ROCm quantizer; upstream requires Python below 3.13.
# Relax NumPy <=2.1.3 because the tree starts at 2.2.6; keep ONNX 1.18 below
# upstream's 1.19 cap. ONNX export also needs unpackaged onnxscript/onnxslim,
# while vLLM's PyTorch paths do not import them.
RDEPEND="
	sci-ml/evaluate[${PYTHON_SINGLE_USEDEP}]
	app-alternatives/ninja
	$(python_gen_cond_dep '
		dev-python/joblib[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		~sci-ml/onnx-1.18.0[${PYTHON_USEDEP}]
		dev-python/pandas[${PYTHON_USEDEP}]
		dev-python/plotly[${PYTHON_USEDEP}]
		dev-python/protobuf[${PYTHON_USEDEP}]
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
