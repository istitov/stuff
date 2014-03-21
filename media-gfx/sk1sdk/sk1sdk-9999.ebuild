# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/gimp/gimp-9999.ebuild,v 1.17 2008/05/18 02:08:03 hanno Exp $

inherit eutils subversion

ESVN_REPO_URI="https://sk1.svn.sourceforge.net/svnroot/sk1/trunk/sk1sdk"
ESVN_PROJECT="${PN}"

MY_R="335"
DESCRIPTION="sK1 vector graphics editor"
HOMEPAGE="http://www.sk1project.org/"

LICENSE="|| ( GPL-2 LGPL-2 )"
SLOT="0"
KEYWORDS=""

IUSE=""

DEPEND=""

RDEPEND="${DEPEND}"

src_compile() {
	python setup.py build || die "'python setup.py build' failed"
}

src_install() {
	python setup.py install --root="${D}" || die "'python setup.py install --root=\"${D}\"' failed"
}
