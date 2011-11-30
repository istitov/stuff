# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit games

DESCRIPTION="Elite space trading & warfare remake"
HOMEPAGE="http://oolite.org/"
SRC_URI="mirror://berlios/oolite-linux/${PN}-dev-source-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="${IUSE}"

RDEPEND="virtual/opengl
		gnustep-base/gnustep-gui
		media-libs/sdl-mixer
		media-libs/sdl-image
		app-accessibility/espeak"

DEPEND="${RDEPEND}
		gnustep-base/gnustep-make"

S="${WORKDIR}/${PN}-dev-source-${PV}"

pkg_setup() {
	GNUSTEP_MAKEFILES=`gnustep-config --variable=GNUSTEP_MAKEFILES` || \
		die "Something went wrong. Can't determine location of gnustep makefiles"
	source "${GNUSTEP_MAKEFILES}/GNUstep.sh"
}

src_prepare() {
	default
	sed '/oolite_LIB_DIRS/d' -i GNUmakefile
	sed "s|/usr/share/GNUstep/Makefiles|${GNUSTEP_MAKEFILES}|" -i Makefile
	sed "s|strip.*|true|" -i GNUmakefile.postamble
}

src_compile() {
	make -f Makefile release || die "make failed"
}

src_install() {
	insinto "${GNUSTEP_LOCAL_ROOT}/Applications"
	doins -r oolite.app || die "install failed"
	echo "openapp oolite" > "${T}/oolite"
	dogamesbin "${T}/oolite"
	prepgamesdirs "${GNUSTEP_LOCAL_ROOT}/Applications"
	fperms ug+x "${GNUSTEP_LOCAL_ROOT}/Applications/oolite.app/oolite"
	doicon installers/FreeDesktop/oolite-icon.png
	domenu installers/FreeDesktop/oolite.desktop
}
