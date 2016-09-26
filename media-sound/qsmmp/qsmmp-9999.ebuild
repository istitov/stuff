# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"
inherit qt4-r2 git-2

HOMEPAGE="http://gitorious.org/qsmmp"
EGIT_REPO_URI="https://gitorious.org/qsmmp/${PN}.git"
EGIT_BRANCH="qmmp-9999"
EGIT_COMMIT="${EGIT_BRANCH}"

DESCRIPTION="Qsmmp is a audio player based on Qmmp. Qsmmp aimed to have native qt look."
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug"

RDEPEND="=media-sound/qmmp-${PV}
		x11-libs/libqxt"

DEPEND="${RDEPEND}"
