# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/firefox-bin/firefox-bin-5.0.ebuild,v 1.1 2011/05/11 20:55:02 anarchy Exp $

EAPI="2"

inherit eutils mozilla-launcher multilib mozextension

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
SRC_URI="${REL_URI}/${MY_PV}/linux-i686/en-US/${MY_P}.tar.bz2
	mirror://gentoo/libnotify.so.1.bz2"
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
	x86? (
		>=x11-libs/gtk+-2.2:2
		 >=media-libs/alsa-lib-1.0.16
	)
	amd64? (
		>=app-emulation/emul-linux-x86-baselibs-20081109
		>=app-emulation/emul-linux-x86-gtklibs-20081109
		>=app-emulation/emul-linux-x86-soundlibs-20081109
	)"

S="${WORKDIR}/${MY_PN}"

pkg_setup() {
	# This is a binary x86 package => ABI=x86
	# Please keep this in future versions
	# Danny van Dyk <kugelfang@gentoo.org> 2005/03/26
	has_multilib_profile && ABI="x86"
}

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
		ewarn "Sorry, but ${PN} does not support the ${LANG} LINGUA"
	done
}

src_unpack() {
	unpack ${MY_P}.tar.bz2
	unpack libnotify.so.1.bz2

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

	# This is a copy of 32bit libnotify.so.1 from app-emulation/emul-linux-x86-gtklibs-20110129.
	# http://bugs.gentoo.org/show_bug.cgi?id=360443.
	exeinto /opt/firefox
	doexe "${WORKDIR}"/libnotify.so.1 || die
}

pkg_postinst() {
	if use x86; then
		if ! has_version 'gnome-base/gconf' || ! has_version 'gnome-base/orbit' \
			|| ! has_version 'net-misc/curl'; then
			einfo
			einfo "For using the crashreporter, you need gnome-base/gconf,"
			einfo "gnome-base/orbit and net-misc/curl emerged."
			einfo
		fi
		if has_version 'net-misc/curl[nss]'; then
			einfo
			einfo "Crashreporter won't be able to send reports"
			einfo "if you have curl emerged with the nss USE-flag"
			einfo
		fi
	else
		einfo
		einfo "NB: You just installed a 32-bit ${MY_P}"
		einfo
		einfo "Crashreporter won't work on amd64"
		einfo
	fi
}

pkg_postrm() {
	update_mozilla_launcher_symlinks
}
