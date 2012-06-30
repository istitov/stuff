# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils python

DESCRIPTION="SOFA is a statistics, analysis, and reporting program"
HOMEPAGE="http://sourceforge.net/projects/sofastatistics/"
SRC_URI="http://sourceforge.net/projects/sofastatistics/files/${PN}/${PV}/sofastats-${PV}.tar.gz/download# -> ${P}.tar.gz"
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-lang/python:2.7[sqlite]
		>=dev-python/wxpython-2.8.11.0
		>=dev-python/numpy-1.5.1
		>=dev-python/pysqlite-2.6.3
		>=dev-python/mysql-python-1.2.3
		>=dev-db/pygresql-3.8.1
		dev-python/matplotlib
		dev-python/pywebkitgtk"

RDEPEND="${DEPEND}"

S="${WORKDIR}/sofastats-${PV}"

src_install(){
	python_convert_shebangs 2 sofa_main/start.py
	dodir /usr/share/sofastats
	insinto /usr/share/sofastats
	doins -r sofa_main/*
	exeinto /usr/share/sofastats
	doexe sofa_main/*.py*
	doexe sofa_main/*/*.py*
	dosym /usr/share/sofastats/start.py /usr/bin/sofastats
	make_desktop_entry sofastats ${PN} /usr/share/sofastats/images/sofa_32x32.ico "Education;Math;"
}