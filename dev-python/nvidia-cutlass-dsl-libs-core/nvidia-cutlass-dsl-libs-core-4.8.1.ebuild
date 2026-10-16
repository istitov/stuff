# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN//-/_}
MY_WHEEL="${MY_PN}-${PV}-py3-none-any.whl"

DESCRIPTION="NVIDIA CUTLASS Python DSL — arch-agnostic core Python package"
HOMEPAGE="
	https://github.com/NVIDIA/cutlass
	https://pypi.org/project/nvidia-cutlass-dsl-libs-core/
"
SRC_URI="
	https://files.pythonhosted.org/packages/6c/03/1c59e3caf7c8b5cae3ae4d1753201c7e64d36cdf182fb882e070b0f14a55/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUTLASS"
SLOT="0"
KEYWORDS="-* ~amd64"
# The CUTLASS EULA restricts redistribution.
RESTRICT="bindist mirror"

# Arch-independent pure-Python core; base and cu13 payloads are disjoint. Omit
# duplicated protobuf metadata because this wheel never imports it. Upstream
# now probes the CUDA Toolkit for nvdisasm itself (root from nvcc on PATH,
# CUDA_HOME/CUDA_PATH, or /usr/local/cuda*), so the lookup patch the 4.6 and
# 4.7 ebuilds carried is obsolete here. verified 2026-09-21
RDEPEND="
	>=dev-python/cuda-python-12.8[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.10.0[${PYTHON_USEDEP}]
	>=dev-util/nvidia-cuda-toolkit-13.3
	<dev-util/nvidia-cuda-toolkit-14
"

BDEPEND+="
	$(python_gen_cond_dep '
		dev-python/installer[${PYTHON_USEDEP}]
	')
"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die

	python_optimize
}
