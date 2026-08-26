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
		https://files.pythonhosted.org/packages/2c/53/a1d91b359a5ddb44a2955dd6f6a0465f27223cd455821d9dabcac3847555/pynvvideocodec-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl
	)
	python_single_target_python3_13? (
		https://files.pythonhosted.org/packages/ba/b1/31f9a5296ef30e17ffafd87c1ad7bdc0a8b42ee8e6a61937ce2e0403b8b3/pynvvideocodec-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl
	)
	python_single_target_python3_14? (
		https://files.pythonhosted.org/packages/6f/ab/6748c9f3d0475f0ebd3bc0f159fc2849663a2a5a7a237140d2cd1d67816d/pynvvideocodec-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl
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
