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
		https://files.pythonhosted.org/packages/60/a9/e4b692f63f7e4085838e7d444b7e5d4a01c6e43843abeff0e31e27ebaf81/pynvvideocodec-${PV}-cp312-cp312-manylinux_2_28_x86_64.whl
	)
	python_single_target_python3_13? (
		https://files.pythonhosted.org/packages/a7/20/34bb7453672e6cb72c125d98c50c764981eb0813c825588aec9d9639f823/pynvvideocodec-${PV}-cp313-cp313-manylinux_2_28_x86_64.whl
	)
	python_single_target_python3_14? (
		https://files.pythonhosted.org/packages/48/f8/bf41ea1d36609b82deaaaa1206b3858eedda8145c5c188bfd3b75cab4611/pynvvideocodec-${PV}-cp314-cp314-manylinux_2_28_x86_64.whl
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
