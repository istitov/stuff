# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils qt4 multilib

DESCRIPTION="ROSA Media Plugin"
HOMEPAGE="http://www.rosalab.ru/"
SRC_URI="http://svn.mandriva.com/svn/packages/cooker/${PN}/current/SOURCES/${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+mpeg +rm +quicktime +wmp +divx"
LANGS="ar bg ca cs de el en_GB es_LA es et eu fi fr gl hu it ja ka ko ku lt mk nl pl pt_PT pt pt_BR ro ru sk sl sr sv tr uk vi zh_CN zh_TW"
for lang in ${LANGS}; do
  IUSE+=" linguas_${lang}"
done

RDEPEND=""
DEPEND="${RDEPEND}
	=media-video/rosa-media-player-${PV}[nsplugin]"

S="${WORKDIR}/rosamp-plugin"

src_compile() {
  if use "rm"; then
	eqmake4 rosamp-plugin-rm.pro
	emake || die
  fi
  
  if use "quicktime"; then
	eqmake4 rosamp-plugin-qt.pro
	emake || die
  fi
  
  if use "wmp"; then
	eqmake4 rosamp-plugin-wmp.pro
	emake || die
  fi
  
  if use "mpeg"; then
	eqmake4 rosamp-plugin-smp.pro
	emake || die
  fi
  
  if use "divx"; then
	eqmake4 rosamp-plugin-dvx.pro
	emake || die
  fi
}
src_install() {
  dodir /usr/$(get_libdir)/nsbrowser/plugins/
  insinto /usr/$(get_libdir)/nsbrowser/plugins/
  doins build/librosa-media-player-plugin-*.so

  for lang in ${LANGS};do
	for x in ${lang};do
	  if ! use linguas_${x}; then
		rm -f "$(find translations -type f -name "rosamp_plugin_${x}*.ts")"
	  fi
	done
  done
  
  for i in $(find translations -type f -name "rosamp_plugin_*.ts");do
	QM="${i%%.ts}.qm"
	lrelease -silent $i -qm "${QM}"
	dodir /usr/$(get_libdir)/mozilla/plugins/translations
	insinto /usr/$(get_libdir)/mozilla/plugins/translations
	doins ${QM}
  done
}
