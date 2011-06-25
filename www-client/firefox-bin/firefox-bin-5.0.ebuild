# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/firefox-bin/firefox-bin-5.0.ebuild,v 1.1 2011/05/11 20:55:02 anarchy Exp $

EAPI="3"

inherit eutils mozilla-launcher mozextension

# Can be updated using scripts/get_langs.sh from mozilla overlay
# '\' at EOL is needed for ${LANG} matching in linguas() below
LANGS="af ak ar ast be bg bn-BD bn-IN br bs ca cs cy da de \
el en en-ZA eo es-ES et eu fa fi fr fy-NL ga-IE gd gl gu-IN \
he hi-IN hr hu hy-AM id is it ja kk kn ko ku lg lt lv mai mk \
ml mr nb-NO nl nn-NO nso or pa-IN pl pt-PT rm ro ru si sk sl \
son sq sr sv-SE ta ta-LK te th tr uk vi zu"
NOSHORTLANGS="en-GB es-AR es-CL es-MX pt-BR zh-CN zh-TW"

MY_PV="${PV/_rc/rc}"
MY_PN="${PN/-bin}"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="Firefox Web Browser"
REL_URI="http://releases.mozilla.org/pub/mozilla.org/${MY_PN}/releases/"
SRC_URI="( x86? ( ${REL_URI}/${MY_PV}/linux-i686/en-US/${MY_P}.tar.bz2 -> firefox_x86-${PV}.tar.bz2 )
		 amd64? ( ${REL_URI}/${MY_PV}/linux-x86_64/en-US/${MY_P}.tar.bz2 -> firefox_x86_64-${PV}.tar.bz2 )
		 )"
HOMEPAGE="http://www.mozilla.com/firefox"
RESTRICT="strip mirror"

KEYWORDS="-* ~amd64 ~x86"
SLOT="0"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="startup-notification"

for X in ${LANGS} ; do
	if [ "${X}" != "en" ] && [ "${X}" != "en-US" ]; then
		SRC_URI="${SRC_URI}
			linguas_${X/-/_}? ( ${REL_URI}/${MY_PV}/linux-i686/xpi/${X}.xpi -> ${P/-bin/}-${X}.xpi )"
	fi
	IUSE="${IUSE} linguas_${X/-/_}"
	# english is handled internally
	if [ "${#X}" == 5 ] && ! has ${X} ${NOSHORTLANGS}; then
		if [ "${X}" != "en-US" ]; then
			SRC_URI="${SRC_URI}
				linguas_${X%%-*}? ( ${REL_URI}/${MY_PV}/linux-i686/xpi/${X}.xpi -> ${P/-bin/}-${X}.xpi )"
		fi
		IUSE="${IUSE} linguas_${X%%-*}"
	fi
done

DEPEND="app-arch/unzip"
RDEPEND="dev-libs/dbus-glib
	x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXmu
	>=x11-libs/gtk+-2.2:2
	>=media-libs/alsa-lib-1.0.16"

S="${WORKDIR}/${MY_PN}"

linguas() {
	local LANG SLANG
	for LANG in ${LINGUAS}; do
		if has ${LANG} en en_US; then
			has en ${linguas} || linguas="${linguas:+"${linguas} "}en"
			continue
		elif has ${LANG} ${LANGS//-/_}; then
			has ${LANG//_/-} ${linguas} || linguas="${linguas:+"${linguas} "}${LANG//_/-}"
			continue
		elif [[ " ${LANGS} " == *" ${LANG}-"* ]]; then
			for X in ${LANGS}; do
				if [[ "${X}" == "${LANG}-"* ]] && \
					[[ " ${NOSHORTLANGS} " != *" ${X} "* ]]; then
					has ${X} ${linguas} || linguas="${linguas:+"${linguas} "}${X}"
					continue 2
				fi
			done
		fi
		ewarn "Sorry, but ${PN} does not support the ${LANG} LING"
	done
}

src_unpack() {
  if use x86;then
	unpack ${MY_PN}_x86-${MY_PV}.tar.bz2
  else
	unpack ${MY_PN}_x86_64-${MY_PV}.tar.bz2
  fi

	linguas
	for X in ${linguas}; do
		[[ ${X} != "en" ]] && xpi_unpack "${P/-bin/}-${X}.xpi"
	done
	if [[ ${linguas} != "" && ${linguas} != "en" ]]; then
		einfo "Selected language packs (first will be default): ${linguas}"
	fi
}

src_install() {
	declare MOZILLA_FIVE_HOME=/opt/${MY_PN}

	# Install icon and .desktop for menu entry
	newicon "${S}"/chrome/icons/default/default48.png ${PN}-icon.png
	domenu "${FILESDIR}"/${PN}.desktop

	# Add StartupNotify=true bug 237317
	if use startup-notification; then
		echo "StartupNotify=true" >> "${D}"/usr/share/applications/${PN}.desktop
	fi

	# Install firefox in /opt
	dodir ${MOZILLA_FIVE_HOME%/*}
	mv "${S}" "${D}"${MOZILLA_FIVE_HOME}

	linguas
	for X in ${linguas}; do
		[[ ${X} != "en" ]] && xpi_install "${WORKDIR}"/"${P/-bin/}-${X}"
	done

	local LANG=${linguas%% *}
	if [[ -n ${LANG} && ${LANG} != "en" ]]; then
		elog "Setting default locale to ${LANG}"
		echo "pref(\"general.useragent.locale\", \"${LANG}\");" > "${D}${MOZILLA_FIVE_HOME}"/defaults/pref/${MY_PN}.js || \
			die "sed failed to change locale"
	fi

		# Create /usr/bin/firefox-bin
if use amd64 ; then
		dodir /usr/bin/
		cat <<EOF >"${D}"/usr/bin/${PN}
#!/bin/sh
unset LD_PRELOAD
LD_LIBRARY_PATH="/opt/firefox/"
GTK_PATH=/usr/lib32/gtk-2.0/
exec /opt/${MY_PN}/${MY_PN} "\$@"
EOF
else
		dodir /usr/bin/
		cat <<EOF >"${D}"/usr/bin/${PN}
#!/bin/sh
unset LD_PRELOAD
LD_LIBRARY_PATH="/opt/firefox/"
GTK_PATH=/usr/lib32/gtk-2.0/
exec /opt/${MY_PN}/${MY_PN} "\$@"
EOF
fi
		fperms 0755 /usr/bin/${PN}

	# revdep-rebuild entry
	insinto /etc/revdep-rebuild
	doins "${FILESDIR}"/10${PN} || die

	rm -rf "${D}"${MOZILLA_FIVE_HOME}/plugins
	dosym /usr/"$(get_libdir)"/nsbrowser/plugins ${MOZILLA_FIVE_HOME}/plugins || die

}

pkg_postrm() {
	update_mozilla_launcher_symlinks
}
