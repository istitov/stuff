# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
LANGS="bg ca cs da de en_US es et eu fi fr gl hr hu it ja ka ko ku lt mk nl pl
pt_BR pt sk sr sv tr zh_CN zh_TW"
LANGSLONG="ar_SY el_GR ro_RO ru_RU sl_SI uk_UA vi_VN"

inherit eutils qt4-r2 subversion

DESCRIPTION="Great Qt4 GUI front-end for mplayer"
HOMEPAGE="http://smplayer.info"
ESVN_REPO_URI="https://subversion.assembla.com/svn/smplayer/smplayer/trunk"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug +skins"

DEPEND="dev-qt/qtgui:4"
MPLAYER_USE="[libass,png,X]"
RDEPEND="${DEPEND}
	|| ( media-video/mplayer${MPLAYER_USE} media-video/mplayer2${MPLAYER_USE} )
	skins? ( x11-themes/smplayer-skins )"

src_prepare() {
	# For Version Branding
	cd "${ESVN_STORE_DIR}/${ESVN_CO_DIR}/${ESVN_PROJECT}/${ESVN_REPO_URI##*/}"
	./get_svn_revision.sh
	mv src/svn_revision.h "${S}"/src/
	mv svn_revision "${S}"/
	cd "${S}"

	# Upstream Makefile sucks
	sed -i -e "/^PREFIX=/s:/usr/local:/usr:" \
		-e "/^DOC_PATH=/s:packages/smplayer:${PF}:" \
		-e '/\.\/get_svn_revision\.sh/,+2c\
	cd src && $(DEFS) $(MAKE)' \
		"${S}"/Makefile || die "sed failed"

	# Turn debug message flooding off
	if ! use debug ; then
		sed -i 's:#\(DEFINES += NO_DEBUG_ON_CONSOLE\):\1:' \
			"${S}"/src/smplayer.pro || die "sed failed"
	fi
}

src_configure() {
	cd "${S}"/src
	eqmake4
}

gen_translation() {
	ebegin "Generating $1 translation"
	lrelease ${PN}_${1}.ts
	eend $? || die "failed to generate $1 translation"
}

src_compile() {
	emake

	# Generate translations
	cd "${S}"/src/translations
	local lang= nolangs= x=
	for lang in ${LINGUAS}; do
		if has ${lang} ${LANGS}; then
			gen_translation ${lang}
			continue
		elif [[ " ${LANGSLONG} " == *" ${lang}_"* ]]; then
			for x in ${LANGSLONG}; do
				if [[ "${lang}" == "${x%_*}" ]]; then
					gen_translation ${x}
					continue 2
				fi
			done
		fi
		nolangs="${nolangs} ${lang}"
	done
	[[ -n ${nolangs} ]] && ewarn "Sorry, but ${PN} does not support the LINGUAS:" ${nolangs}
	# install fails when no translation is present (bug 244370)
	[[ -z $(ls *.qm 2>/dev/null) ]] && gen_translation en_US
}

src_install() {
	# remove unneeded copies of GPL
	rm -f Copying.txt docs/{cs,en,hu,it,ja,pt,ru,zh_CN}/gpl.html || die
	rm -rf docs/{de,es,nl,ro} || die

	emake DESTDIR="${D}" install
}
