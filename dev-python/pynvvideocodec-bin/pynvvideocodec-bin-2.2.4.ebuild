# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DISTUTILS_USE_PEP517=no
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1

DESCRIPTION="Python bindings for NVIDIA Video Codec SDK"
HOMEPAGE="https://developer.nvidia.com/pynvvideocodec"
SRC_URI="
	python_single_target_python3_12? (
		https://files.pythonhosted.org/packages/55/f6/0544f02e89f76459c08da68bda208d4432654e18a378afe34df0728888c9/pynvvideocodec-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl
	)
	python_single_target_python3_13? (
		https://files.pythonhosted.org/packages/22/3d/53e8d7593ed773a3ce4060d9636f65d28db216d3d5908cacd71353c73a87/pynvvideocodec-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl
	)
	python_single_target_python3_14? (
		https://files.pythonhosted.org/packages/a0/72/a39081ab3d92033e3cf09e64e09aafd1c8242d1c0499bb9c7ed1127b74c8/pynvvideocodec-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl
	)
"
S=${WORKDIR}
LICENSE="MIT LGPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"
QA_PREBUILT="
	usr/lib*/python*/site-packages/PyNvVideoCodec/*.so*
	usr/lib*/python*/site-packages/pynvvideocodec.*/*.so*
"

BDEPEND+="
	$(python_gen_cond_dep '
		dev-python/installer[${PYTHON_USEDEP}]
	')
"

python_install() {
	local wheel
	case ${EPYTHON} in
		python3.12) wheel=pynvvideocodec-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl ;;
		python3.13) wheel=pynvvideocodec-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl ;;
		python3.14) wheel=pynvvideocodec-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl ;;
		*) die "unsupported Python implementation: ${EPYTHON}" ;;
	esac
	${EPYTHON} -m installer --destdir="${D}" "${DISTDIR}/${wheel}" || die
}
