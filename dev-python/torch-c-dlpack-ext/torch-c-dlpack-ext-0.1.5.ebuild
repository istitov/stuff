# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Companion DLPack C-exchange-API ext for older torch builds"
HOMEPAGE="
	https://github.com/apache/tvm-ffi
	https://pypi.org/project/torch-c-dlpack-ext/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Custom build_backend.py: at wheel build time it inspects the
# installed torch — if torch.Tensor already has __dlpack_c_exchange_api__
# (true for 2.11+) the package installs as pure-Python; otherwise it
# subprocess-invokes tvm_ffi.utils._build_optional_torch_c_dlpack to
# compile a native .so against the detected CUDA/ROCm runtime, which
# pulls apache-tvm-ffi at build time. We declare apache-tvm-ffi as a
# BDEPEND defensively — cheap, and avoids a surprise on hosts that
# rebuild after a torch downgrade. # verified 2026-05-07 against 0.1.5.
RDEPEND="
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/apache-tvm-ffi[${PYTHON_USEDEP}]
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
	# verified 2026-05-07 against 0.1.5.
	rm -f "${ED}"/usr/lib/python*/site-packages/build_backend.py || die
	rm -rf "${ED}"/usr/lib/python*/site-packages/__pycache__/build_backend.* || die
}
