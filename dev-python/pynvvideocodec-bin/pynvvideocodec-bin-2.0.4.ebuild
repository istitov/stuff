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
		https://files.pythonhosted.org/packages/ca/49/98da271686e00676f41b1197ba5431ddc341b96d8efb68ea9d68e2b0d870/pynvvideocodec-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl
	)
	python_single_target_python3_13? (
		https://files.pythonhosted.org/packages/46/d6/8475720d4f0f8fc9e852e0092b308643b71f24d9495ba3bd03c38b16c28d/pynvvideocodec-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl
	)
	python_single_target_python3_14? (
		https://files.pythonhosted.org/packages/a7/ce/3062bf51bc0d98a344b9ed229a40535f6f1d309fc9ffaf34719b67ed3e21/pynvvideocodec-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl
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
