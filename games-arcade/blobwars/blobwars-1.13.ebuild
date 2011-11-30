# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/games-arcade/blobwars/Attic/blobwars-1.08.ebuild,v 1.9 2008/08/16 20:31:23 mr_bones_ dead $

EAPI=2

inherit eutils gnome2-utils games

DESCRIPTION="Platform game about a blob and his quest to rescue MIAs from an alien invader"
HOMEPAGE="http://www.parallelrealities.co.uk/projects/blobWars.php"
SRC_URI="http://www.parallelrealities.co.uk/download/${PN}/${P}-1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND="media-libs/libsdl
	media-libs/sdl-mixer
	media-libs/sdl-ttf
	media-libs/sdl-image
	virtual/libintl"
DEPEND="${RDEPEND}
	sys-devel/gettext"

src_prepare() {
	# don't build the pak file in the install stage.
	sed -i \
		-e "98d" makefile || die "sed failed"
	epatch "${FILESDIR}/${PN}-1.13-no-werror.patch"
}

src_compile() {
	emake \
		DATADIR="${GAMES_DATADIR}/${PN}/" \
		DOCDIR="/usr/share/doc/${PF}/html/" \
		LOCALEDIR="/usr/share/locale/" \
		|| die "emake failed"
	emake buildpak || die "emake failed"
}

src_install() {
	emake \
		DESTDIR="${D}" \
		BINDIR="${D}/${GAMES_BINDIR}/" \
		DATADIR="${D}/${GAMES_DATADIR}/${PN}/" \
		DOCDIR="${D}/usr/share/doc/${PF}/html/" \
		ICONDIR="${D}/usr/share/icons/hicolor/" \
		DESKTOPDIR="${D}/usr/share/applications/" \
		LOCALEDIR="${D}/usr/share/locale/" \
		install || die "emake install failed"
	# now make the docs Gentoo friendly.
	dodoc "${D}/usr/share/doc/${PF}/html/"{changes,hacking,porting,readme}
	rm -f "${D}/usr/share/doc/${PF}/html/"{changes,hacking,porting,readme}
	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
