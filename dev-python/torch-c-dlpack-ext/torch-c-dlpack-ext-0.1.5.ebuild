# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="AOT-compiled DLPack exchange extension for PyTorch"
HOMEPAGE="
	https://github.com/apache/tvm-ffi
	https://pypi.org/project/torch-c-dlpack-ext/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

DOCS=( NOTICE README.md )

# The PyPI sdist ships no tests. Its custom backend imports PyTorch and skips
# native compilation when Tensor already provides the DLPack exchange API;
# otherwise it uses apache-tvm-ffi to build an extension against PyTorch.
# verified 2026-08-04 against 0.1.5.
RDEPEND="
	$(python_gen_cond_dep '
		dev-python/packaging[${PYTHON_USEDEP}]
	')
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
"
DEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.1[${PYTHON_USEDEP}]
	')
"

python_install_all() {
	distutils-r1_python_install_all

	# Upstream's pyproject.toml lists "build_backend" as a top-level
	# py-module so it ships at /usr/lib/pythonX.Y/site-packages/
	# build_backend.py — a global-namespace name with a generic
	# import, polluting every interpreter that imports the package.
	# The module is only needed at PEP 517 build time. Drop it
	# post-install rather than carry a one-line pyproject.toml patch.
	# verified 2026-08-04 against 0.1.5.
	rm -f "${ED}"/usr/lib/python*/site-packages/build_backend.py || die
	rm -rf "${ED}"/usr/lib/python*/site-packages/__pycache__/build_backend.* || die
}
