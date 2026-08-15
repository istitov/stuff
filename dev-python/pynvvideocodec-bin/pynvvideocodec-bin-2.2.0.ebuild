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
		https://files.pythonhosted.org/packages/6b/1d/e5601e313855234ae4a8e6d9883e0b99dad2016625cc379f03755f81d0eb/pynvvideocodec-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl
	)
	python_single_target_python3_13? (
		https://files.pythonhosted.org/packages/4c/0e/ebdf5fa81ac1bb216113888e74f0c2ab9782061f9e424c363847e9cf48c5/pynvvideocodec-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl
	)
	python_single_target_python3_14? (
		https://files.pythonhosted.org/packages/9d/76/2a4b07115b18d9295edb1d525d89d524ca5b484e9f4200a0f92191615d51/pynvvideocodec-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl
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
