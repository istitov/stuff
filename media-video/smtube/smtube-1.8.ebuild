# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PLOCALES="cs el en es eu fi gl he_IL hu ja ka lt ms_MY nn_NO pl pt_BR pt ru_RU sv tr uk zh_CN"
inherit l10n qt4-r2

DESCRIPTION="A youtube search and play add-on for smplayer"
HOMEPAGE="http://smplayer.sourceforge.net/"
SRC_URI="mirror://sourceforge/smplayer/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-qt/qtgui:4"
RDEPEND="${RDEPEND}
	media-video/smplayer"

src_prepare() {
	remove_translation() {
		sed -i -e "s:translations/${PN}_${1}.ts::" src/${PN}.pro || die "removing translation ${1} from src/${PN}.pro failed"
	}

	sed -i \
		-e '/^PREFIX=/s:/usr/local:/usr:' \
		-e "/^DOC_PATH/s:${PN}:${PF}:" \
		-e 's/&& $(QMAKE) $(QMAKE_OPTS)//' \
		Makefile || die "sed on Makefile failed"

	echo "#define SVN_REVISION \"SVN-${PV} (Gentoo)\"" > src/svn_revision.h

	# remove unneeded files
	rm Copying.txt Copying_BSD.txt || die 'remove unneeded files failed'

	l10n_find_plocales_changes "src/translations" "${PN}_" '.ts'
	l10n_for_each_disabled_locale_do remove_translation

	qt4-r2_src_prepare
}

src_configure() {
	pushd src &>/dev/null || die 'failed to change directory'
	eqmake4
	popd &>/dev/null
}
