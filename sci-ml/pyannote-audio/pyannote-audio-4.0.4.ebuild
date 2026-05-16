# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
PYPI_PN="pyannote.audio"

inherit distutils-r1 pypi

DESCRIPTION="State-of-the-art speaker diarization toolkit (PyTorch)"
HOMEPAGE="
	https://github.com/pyannote/pyannote-audio
	https://pyannote.github.io/
	https://pypi.org/project/pyannote.audio/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cli"

# Note: actually running speaker diarization at runtime additionally
# requires a pretrained model from HuggingFace Hub (e.g. the
# pyannote/speaker-diarization-3.1 repo), which the user fetches
# themselves with `huggingface-cli login` after accepting the model
# terms on https://huggingface.co/pyannote/. The Python package
# itself doesn't need it to import.
#
# scipy, scikit-learn, networkx, tqdm, and pyyaml are absent from
# upstream pyproject.toml but imported at module top level by core
# pipeline modules (clustering, signal, vbx, calibration, permutation,
# __main__, pipeline) — verified against the 4.0.4 source 2026-05-16.
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	sci-ml/torchaudio[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/torchcodec-0.7[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/torchmetrics-1.6.1[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/lightning-2.4[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/asteroid-filterbanks-0.4.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/torch-audiomentations-0.12.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/pytorch-metric-learning-2.8.1[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/huggingface_hub-0.28.1[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=sci-ml/pyannote-core-6.0.1[${PYTHON_USEDEP}]
		>=sci-ml/pyannote-database-6.1.1[${PYTHON_USEDEP}]
		>=sci-ml/pyannote-metrics-4.0[${PYTHON_USEDEP}]
		>=sci-ml/pyannote-pipeline-4.0.0[${PYTHON_USEDEP}]
		>=sci-ml/pyannoteai-sdk-0.3.0[${PYTHON_USEDEP}]
		>=sci-ml/safetensors-0.5.2[${PYTHON_USEDEP}]
		>=dev-python/einops-0.8.1[${PYTHON_USEDEP}]
		>=dev-python/matplotlib-3.10.0[${PYTHON_USEDEP}]
		dev-python/networkx[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-api-1.34.0[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-sdk-1.34.0[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-exporter-otlp-1.34.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-6.0.2[${PYTHON_USEDEP}]
		>=dev-python/rich-13.9.4[${PYTHON_USEDEP}]
		dev-python/scikit-learn[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		cli? ( >=dev-python/typer-0.15.1[${PYTHON_USEDEP}] )
	')
"

# Tests need papermill + a pre-downloaded HF model bundle.
RESTRICT="test"
