# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="http://sourceforge.net/projects/sofastatistics/"
HOMEPAGE="http://sourceforge.net/projects/sofastatistics/"
SRC_URI="http://sourceforge.net/projects/sofastatistics/files/${PN}/${PV}/sofastats-${PV}.tar.gz/download# -> ${P}.tar.gz"
LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=">=dev-lang/python-2.6.2
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
  dodir /usr/share/sofastats
  cp -R sofa_main/* ${D}usr/share/sofastats
  exeinto /usr/share/sofastats
  doexe sofa_main/*.py*
  doexe sofa_main/*/*.py*
  dosym  /usr/share/sofastats/start.py /usr/bin/sofastats
}