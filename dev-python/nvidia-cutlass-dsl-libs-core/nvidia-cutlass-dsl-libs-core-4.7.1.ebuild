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
	https://files.pythonhosted.org/packages/6b/14/b669cc890f7fd74008d7bc52f493d0a7ff256de10f3941c6676249419c07/${MY_WHEEL}
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUTLASS"
SLOT="0"
KEYWORDS="-* ~amd64"
# The CUTLASS EULA restricts redistribution.
RESTRICT="bindist mirror"

# Arch-independent pure-Python core; base and cu13 payloads are disjoint. Omit
# duplicated protobuf metadata because this wheel never imports it; patch
# nvdisasm lookup for system CUDA. verified 2026-08-26
RDEPEND="
	>=dev-python/cuda-python-12.8[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.10.0[${PYTHON_USEDEP}]
	>=dev-util/nvidia-cuda-toolkit-13.3
	<dev-util/nvidia-cuda-toolkit-14
"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	cp "${DISTDIR}/${MY_WHEEL}" "${S}/wheel/" || die
}

python_install() {
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${MY_WHEEL}" || die

	local sp="${D}$(${EPYTHON} -c 'import sysconfig; print(sysconfig.get_path("purelib"))')"
	pushd "${sp}/nvidia_cutlass_dsl" >/dev/null || die
	eapply "${FILESDIR}/${PN}-4.6-system-nvdisasm.patch"
	popd >/dev/null || die
	python_optimize
}
