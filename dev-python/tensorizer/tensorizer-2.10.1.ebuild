# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Fast PyTorch module/model/tensor serialization + deserialization"
HOMEPAGE="
	https://github.com/coreweave/tensorizer
	https://pypi.org/project/tensorizer/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	>=sci-ml/pytorch-1.9.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/numpy-1.19.5[${PYTHON_USEDEP}]
		>=dev-python/protobuf-3.19.5[${PYTHON_USEDEP}]
		>=dev-python/psutil-5.9.4[${PYTHON_USEDEP}]
		>=dev-python/boto3-1.26.0[${PYTHON_USEDEP}]
		>=dev-python/redis-4.5.5[${PYTHON_USEDEP}]
		>=dev-python/hiredis-2.2.0[${PYTHON_USEDEP}]
		>=dev-python/libnacl-2.1.0[${PYTHON_USEDEP}]
	')
"
