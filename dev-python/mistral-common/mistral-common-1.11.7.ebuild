# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
PYPI_NO_NORMALIZE=1
PYPI_PN=mistral_common

inherit distutils-r1 pypi

DESCRIPTION="Mistral-common: library of common utilities for Mistral AI"
HOMEPAGE="
	https://github.com/mistralai/mistral-common
	https://pypi.org/project/mistral_common/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="image"

# vllm uses mistral_common[image] which adds opencv-python-headless;
# media-libs/opencv with USE=python serves the same role.  The installed
# console script also imports the server dependencies directly.
RDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/pydantic-2.7[${PYTHON_USEDEP}]
		>=dev-python/tiktoken-0.7.0[${PYTHON_USEDEP}]
	' python3_{12..13})
	$(python_gen_cond_dep '
		>=dev-python/pydantic-2.12[${PYTHON_USEDEP}]
		>=dev-python/tiktoken-0.12.0[${PYTHON_USEDEP}]
	' python3_14)
	$(python_gen_cond_dep '
		>=dev-python/numpy-1.25[${PYTHON_USEDEP}]
		<dev-python/numpy-2.4[${PYTHON_USEDEP}]
	' python3_12)
	$(python_gen_cond_dep '
		>=dev-python/numpy-1.25[${PYTHON_USEDEP}]
	' python3_{13..14})
	>=dev-python/jsonschema-4.21.1[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.11.0[${PYTHON_USEDEP}]
	>=dev-python/pillow-10.3.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-extra-types-2.10.5[${PYTHON_USEDEP}]
	dev-python/pycountry[${PYTHON_USEDEP}]
	>=dev-python/fastapi-0.118.3[${PYTHON_USEDEP}]
	>=dev-python/pydantic-settings-2.9.1[${PYTHON_USEDEP}]
	>=dev-python/click-8.1.0[${PYTHON_USEDEP}]
	dev-python/uvicorn[${PYTHON_USEDEP}]
	image? ( >=media-libs/opencv-4.0.0[python,${PYTHON_USEDEP}] )
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# Other tests need optional extras or fixtures omitted from the sdist.
	epytest \
		tests/test_base.py \
		tests/test_deprecation.py \
		tests/test_image.py \
		tests/test_imports.py \
		tests/test_model_settings.py
	"${EPYTHON}" -c \
		"from mistral_common.experimental.app.main import cli; assert cli.name == 'cli'" || die
}
