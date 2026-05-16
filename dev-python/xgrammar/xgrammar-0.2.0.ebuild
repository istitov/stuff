# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 pypi

DESCRIPTION="Efficient, flexible structured generation engine for LLMs"
HOMEPAGE="
	https://xgrammar.mlc.ai/
	https://github.com/mlc-ai/xgrammar
	https://pypi.org/project/xgrammar/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# vllm pins >=0.1.32, <1.0.0; 0.2.0 fits.
# Upstream also lists `triton` as a runtime dep on Linux x86_64, but
# triton isn't packaged in ::gentoo or here yet — vllm + xgrammar's
# grammar-matching paths we exercise don't require it. # verified 2026-05-10
RDEPEND="
	>=sci-ml/pytorch-1.10.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.38.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/apache-tvm-ffi-0.1.9[${PYTHON_USEDEP}]
		dev-python/pydantic[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.9.0[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	>=dev-build/cmake-3.18
	$(python_gen_cond_dep '
		>=dev-python/nanobind-2.5.0[${PYTHON_USEDEP}]
	')
"

python_install_all() {
	distutils-r1_python_install_all

	# FIXME: workaround, not proper fix.
	# xgrammar/load_binding.py calls tvm_ffi's load_lib_module without
	# passing extra_lib_paths, so tvm_ffi searches only its own lib/
	# dirs and a few PATH entries. The .so installed at xgrammar/
	# libxgrammar_bindings.so is invisible to that search. Symlink it
	# into tvm_ffi's lib/ so the lookup succeeds. Upstream wheel works
	# only by accident (their wheel layout differs from a normal
	# site-packages install). # verified 2026-05-16 against 0.2.0:
	# without this symlink, `from vllm import LLM` dies during
	# xgrammar module init.
	#
	# Upstream-able fix: patch xgrammar/load_binding.py to pass
	# `extra_lib_paths=[Path(__file__).parent]` to load_lib_module —
	# self-contained inside xgrammar's package boundary, no
	# cross-package symlink dance. Switch to that pattern (and ship
	# the patch in files/) when there's appetite for a maintained
	# patch rather than this dosym workaround.  Also remove the
	# symlink risk: a hypothetical future apache-tvm-ffi shipping its
	# own libxgrammar_bindings.so would collide here.
	local sp
	sp=$(${EPYTHON} -c 'import sysconfig; print(sysconfig.get_path("purelib"))') || die
	local tvm_lib="${ED}${sp}/tvm_ffi/lib"
	dodir "${tvm_lib#${ED}}"
	dosym "${sp}/xgrammar/libxgrammar_bindings.so" "${tvm_lib#${ED}}/libxgrammar_bindings.so"
}
