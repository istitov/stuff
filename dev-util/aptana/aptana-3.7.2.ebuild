# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="The leading eclipse IDE for Ajax and today's web platforms"
HOMEPAGE="http://www.aptana.com"
SRC_URI="https://github.com/aptana/studio3/releases/download/3.7.2.201807301111/aptana.studio-linux.gtk.x86_64.zip"
LICENSE="EPL-1.0"
SLOT="3"
KEYWORDS="amd64"
RESTRICT="mirror"
IUSE=""

DEPEND="app-arch/unzip"

RDEPEND="media-libs/libjpeg-turbo
	 >=virtual/jre-1.5
	 media-libs/libpng
	 x11-libs/gtk+:2
	 sys-apps/net-tools
	"
S=${WORKDIR}
src_install(){
	einfo "Installing Aptana"
	dodir "/opt/${PN}"
	local dest="${D}/opt/${PN}"
	cp -pPR ${S} "${dest}" || die "Failed to install Files"
	insinto "/opt/${PN}"
	#doins libcairo-swt.so icon.xpm about.html AptanaStudio3.ini full_uninstall.txt version.txt
	exeinto "/opt/${PN}"
	doexe AptanaStudio3

	dodir /opt/bin
	echo "#!/bin/sh" > ${T}/AptanaStudio
	echo "/opt/${PN}/AptanaStudio3" >> ${T}/AptanaStudio
	dobin "${T}/AptanaStudio"

	make_desktop_entry "AptanaStudio" "Aptana Studio" "/opt/${PN}/icon.xpm" "Development"
}
