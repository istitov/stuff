# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Library for utilizing the safetensors format with compressed tensors"
HOMEPAGE="
	https://github.com/vllm-project/compressed-tensors
	https://pypi.org/project/compressed-tensors/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=sci-ml/pytorch-2.10.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.45.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/pydantic-2.0[${PYTHON_USEDEP}]
		dev-python/loguru[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/setuptools-scm-8[${PYTHON_USEDEP}]
	')
"

# setuptools-scm derives the version from git tags; the sdist bundles
# the version but the build still introspects, so pretend the version.
# Upstream's pyproject.toml pins setuptools_scm==8.2.0 but the
# format_next_version / format_with API is stable across 8/9/10 and
# the strict pin would force an old setuptools-scm into our overlay.
export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
