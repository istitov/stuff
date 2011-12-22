# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: megabaks Exp $

EAPI=4

inherit eutils

RESTRICT_PYTHON_ABIS="2.*"
DESCRIPTION="Media player with VK/Last.fm integration"
HOMEPAGE="https://launchpad.net/~foobnix-player"
SRC_URI="https://launchpad.net/~foobnix-player/+archive/${PN}/+files/${PN}_${PV}o.tar.gz"

LICENSE="GPLv3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc64 ~sparc ~x86"
IUSE="hotkeys dvb alsa fuse libnotify lame faac mp3 webkit"
DEPEND="dev-python/chardet
		dev-python/gst-python
		net-libs/glib-networking[ssl]
		dev-python/simplejson
		dev-python/pygtk
		media-libs/gst-plugins-good
		media-plugins/gst-plugins-soup
		media-plugins/gst-plugins-ffmpeg
		sys-devel/gettext
		virtual/ffmpeg
		hotkeys? ( dev-libs/keybinder )
		dvb? ( media-libs/gst-plugins-bad )
		alsa? ( media-plugins/gst-plugins-alsa )
		fuse? ( sys-fs/fuseiso )
		libnotify? ( dev-python/notify-python )
		lame? ( media-sound/lame )
		faac? ( media-libs/faac )
		mp3? ( media-libs/gst-plugins-ugly )
		webkit? ( dev-python/pywebkitgtk )"

LANGS="bg de en_GB es fr it pl pt ru tr uk zh_CN"
for lang in ${LANGS}; do
	IUSE+=" linguas_${lang}"
done

S="${WORKDIR}/${PN}_${PV}"

src_compile(){
  emake || die "compile"
}
src_install(){
  mkdir hack  
  for lang in ${LANGS}; do
	if ! use linguas_${lang}; then
	  rm "po/${lang}.po" || die
	fi
  done
  emake PREFIX=hack install || die "install"
  mkdir "${D}/usr"
  cp -R hack/* "${D}"/usr || die "install"
}
