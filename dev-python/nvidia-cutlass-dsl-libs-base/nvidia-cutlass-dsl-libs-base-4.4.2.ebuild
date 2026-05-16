# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_PN=${PN//-/_}
MY_BASE="https://files.pythonhosted.org/packages"

DESCRIPTION="NVIDIA CUTLASS Python DSL — base shared libs"
HOMEPAGE="
	https://github.com/NVIDIA/cutlass
	https://pypi.org/project/nvidia-cutlass-dsl-libs-base/
"
SRC_URI="
	python_targets_python3_12? ( ${MY_BASE}/56/98/e264964741d9cc9816625d9600d17a5249fd5cbd8c2d166fb0d0c34dfe5a/${MY_PN}-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl )
	python_targets_python3_13? ( ${MY_BASE}/e1/68/27380038ebd9c8eab4be364e833fea144aef597704f44948921668f7adf4/${MY_PN}-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl )
	python_targets_python3_14? ( ${MY_BASE}/4b/ae/0998f328b28b956d7eb399d16f4ee681ca318b306007264444a623e86c64/${MY_PN}-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl )
"
S="${WORKDIR}"

LICENSE="NVIDIA-CUDA"
SLOT="0"
KEYWORDS="-* ~amd64"
# NVIDIA-CUDA is an EULA license; distfiles must not be mirrored,
# binpkgs must not be redistributed.
RESTRICT="bindist mirror"

# Wheel-only on PyPI (binary CUDA-shared bits with no source release).
# Sub-package of the nvidia-cutlass-dsl umbrella; required by the
# parent's base install.
RDEPEND="
	dev-python/cuda-python[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

QA_PREBUILT="usr/lib/python3.*/site-packages/cutlass/*"

src_unpack() {
	mkdir -p "${S}/wheel" || die
	local f
	for f in ${A}; do
		cp "${DISTDIR}/${f}" "${S}/wheel/" || die
	done
}

src_install() {
	python_foreach_impl install_wheel
}

install_wheel() {
	local pyver=${EPYTHON#python}
	local cptag=cp${pyver//./}
	local whl="${MY_PN}-${PV}-${cptag}-${cptag}-manylinux_2_28_x86_64.whl"
	[[ -f ${S}/wheel/${whl} ]] || die "expected wheel ${whl} not found"
	${EPYTHON} -m installer --destdir="${D}" "${S}/wheel/${whl}" || die

	# This wheel and the sibling nvidia-cutlass-dsl-libs-cu13 wheel
	# overlap on file paths but ship subtly different *contents* at
	# those paths (CUDA-13 builds vs the base build). pip's behaviour
	# when both are installed is "cu13 overwrites base"; Portage's
	# collision-protect would error instead.
	#
	# 4.4.2 oddity: unlike 4.5.x (where base ships 3 files unique to
	# itself — LICENSE / libcuda_dialect_runtime_static.a / utils/
	# block.py), in 4.4.2 *every* file in base's nvidia_cutlass_dsl/
	# tree is also present in cu13. Verified 2026-05-16 by diffing the
	# two cp313 wheels. So libs-base on 4.4.2 keeps only its dist-info
	# (so portage sees it installed for dep resolution) and lets cu13
	# own the entire shared tree + the .pth bootstrap.
	local sp="${D}$(${EPYTHON} -c 'import sysconfig; print(sysconfig.get_path("purelib"))')"
	local nvdir="${sp}/nvidia_cutlass_dsl"
	[[ -d ${nvdir} ]] && rm -rf "${nvdir}"
	rm -f "${sp}/nvidia_cutlass_dsl.pth" || die
}
