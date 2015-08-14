# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python3_4 )
inherit eutils cmake-utils python-single-r1

DESCRIPTION="Boost.Python interface for NumPy"
HOMEPAGE="https://github.com/ndarray/Boost.NumPy"
if [ ${PV} == 9999 ]; then
	inherit git-2
	EGIT_REPO_URI="git://github.com/ndarray/Boost.NumPy.git \
		https://github.com/ndarray/Boost.NumPy.git"
else
	SRC_URI="http://github.com/ndarray/Boost.NumPy/archive/master.tar.gz -> ${P}-git.tar.gz"
fi

LICENSE="Boost-1.0"
SLOT=0
IUSE="doc examples"
KEYWORDS="~amd64"

CDEPEND="dev-python/numpy
	dev-libs/boost[python]"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

S=${WORKDIR}/Boost.NumPy-master

src_prepare() {
	sed -i -e "s/python3/python-${EPYTHON#python}/g" CMakeLists.txt
}

src_install() {
	cmake-utils_src_install

	use doc && dodoc -r libs/numpy/doc/*
	use examples && dodoc -r libs/numpy/example
}
