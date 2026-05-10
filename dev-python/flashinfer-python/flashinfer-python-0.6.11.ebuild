# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=standalone
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="FlashInfer: kernel library for LLM serving (Python frontend)"
HOMEPAGE="
	https://github.com/flashinfer-ai/flashinfer
	https://pypi.org/project/flashinfer-python/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Pure-Python wheel install at packaging time; the C++ csrc/include
# and vendored cutlass/spdlog ride along as data files for runtime
# JIT compilation. No nvcc invocation here, so the gcc-15 host-pin
# isn't needed at install-time. (At first JIT invocation by a user,
# nvcc will be exercised — that path remains the user's responsibility
# to align with the gcc-15 / nvcc compatibility window.)
RDEPEND="
	>=dev-python/apache-tvm-ffi-0.1.6[${PYTHON_USEDEP}]
	<dev-python/apache-tvm-ffi-0.2[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/cuda-tile-bin[${PYTHON_USEDEP}]
	dev-python/einops[${PYTHON_USEDEP}]
	app-alternatives/ninja
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/nvidia-cudnn-frontend-1.13.0[${PYTHON_USEDEP}]
	>=dev-python/nvidia-cutlass-dsl-4.5.0[${PYTHON_USEDEP}]
	dev-python/nvidia-ml-py[${PYTHON_USEDEP}]
	>=dev-python/packaging-24.2[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/tabulate[${PYTHON_USEDEP}]
	sci-ml/pytorch[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	~dev-python/flashinfer-cubin-${PV}[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-python/setuptools-77[${PYTHON_USEDEP}]
	>=dev-python/packaging-24[${PYTHON_USEDEP}]
	>=dev-python/apache-tvm-ffi-0.1.6[${PYTHON_USEDEP}]
"

python_install_all() {
	distutils-r1_python_install_all

	# Upstream's [tool.setuptools] py-modules = ["build_backend",
	# "build_utils"] would leak both PEP-517 backend wrappers into
	# top-level site-packages, polluting the global namespace and
	# pulling setuptools into runtime. Same shape as the
	# dev-python/torch-c-dlpack-ext fix; drop both in install_all.
	# verified 2026-05-07 against 0.6.8.post1.
	rm -f "${ED}"/usr/lib/python*/site-packages/build_backend.py || die
	rm -f "${ED}"/usr/lib/python*/site-packages/build_utils.py || die
	rm -rf "${ED}"/usr/lib/python*/site-packages/__pycache__/build_backend.* || die
	rm -rf "${ED}"/usr/lib/python*/site-packages/__pycache__/build_utils.* || die
}
