# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="PyTorch VRAM allocator with on-demand weight offloading (binary wheel)"
HOMEPAGE="https://pypi.org/project/comfy-aimdo/"
# No sdist upstream. USE=cuda installs the cp39-abi3 manylinux CUDA wheel for
# the host arch (NVIDIA, on-demand GPU offloading); without cuda the
# py3-none-any pure-python wheel -- importable everywhere but a no-op allocator
# (CPU/ROCm fallback).
#
# The cuda branch is per-arch: this ebuild is keyworded ~arm64 as well, and
# upstream ships an aarch64 build, so a single x86_64 URL would install an
# x86_64 .so on arm64 and fail at import. # verified 2026-09-09
SRC_URI="
	cuda? (
		amd64? ( https://files.pythonhosted.org/packages/1a/bc/aa38d79aed78aee21d1186e056f8b8e348c6af78874d6f7ed257a6dddf5d/comfy_aimdo-${PV}-cp39-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.whl )
		arm64? ( https://files.pythonhosted.org/packages/96/5a/f38fd0c29a75daf40e62ee7b78b4889a622f12666e7e87e847eab7b8979f/comfy_aimdo-${PV}-cp39-abi3-manylinux2014_aarch64.manylinux_2_17_aarch64.whl )
	)
	!cuda? ( https://files.pythonhosted.org/packages/e4/ef/9a94b88981e51dea163f2fdf98cd28424276fab6a31dc7e22ce89018778f/comfy_aimdo-${PV}-py3-none-any.whl )
"
S="${WORKDIR}"

# PyPI metadata omits the license; the wheel's bundled LICENSE is GPL-3.0.
# verified 2026-06-16
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
IUSE="cuda"
RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/lib/python3.*/site-packages/comfy_aimdo/*"

# ComfyUI hard-imports comfy_aimdo at module load (execution.py,
# model_management.py, model_patcher.py, pinned_memory.py), so the package is
# mandatory. The cuda wheel needs the NVIDIA driver + CUDA 12.8+ runtime at
# import; the py3-none-any fallback imports anywhere (no GPU offloading).

src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/" || die
}

src_compile() { :; }

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${WORKDIR}/${A}" || die
	python_optimize
}
