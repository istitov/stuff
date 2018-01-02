# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit qmake-utils git-r3

HOMEPAGE="https://github.com/ksv1986/qsmmp"
EGIT_REPO_URI="https://github.com/ksv1986/${PN}.git"

DESCRIPTION="Qsmmp is a audio player based on Qmmp. Qsmmp aimed to have native qt look."
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug"

RDEPEND="=media-sound/qmmp-${PV}
		x11-libs/libqxt"

DEPEND="${RDEPEND}"
