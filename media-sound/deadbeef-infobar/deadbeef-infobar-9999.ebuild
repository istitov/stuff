# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/deadbeef-infobar/deadbeef-infobar-9999.ebuild,v 1 2011/05/20 00:13:35 megabaks Exp $

EAPI=4

DESCRIPTION="Infobar plugin for DeadBeeF audio player. Shows lyrics and artist's biography for the current track."
HOMEPAGE="https://bitbucket.org/Not_eXist/deadbeef-infobar"
EHG_REPO_URI="https://hg@bitbucket.org/Not_eXist/deadbeef-infobar"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc64 ~sparc ~x86"
IUSE=""

DEPEND_COMMON="
		x11-libs/gtk+
		dev-libs/libxml2"
		
RDEPEND="
	${DEPEND_COMMON}
	"
DEPEND="
	${DEPEND_COMMON}
	"
S="${WORKDIR}"

src_prepare() {
  hg clone $EHG_REPO_URI
 }

src_configure() {
  cd deadbeef-infobar/ 
  cmake .
  }
  
src_compile() {
  cd deadbeef-infobar/
  emake || die
  }

src_install() {
  cd deadbeef-infobar/ 
  insinto /usr/lib/deadbeef
  doins ddb_infobar.so
  }