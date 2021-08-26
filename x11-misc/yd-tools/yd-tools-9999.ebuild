# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..8} )
PLOCALES="be bg el ru"

inherit desktop eutils plocale python-r1 xdg-utils

DESCRIPTION="A panel indicator (GUI) for YandexDisk CLI client"
HOMEPAGE="https://github.com/slytomcat/yandex-disk-indicator"

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/slytomcat/yandex-disk-indicator"
else
	MY_P="yandex-disk-indicator-${PV}"
	SRC_URI="https://github.com/slytomcat/yandex-disk-indicator/archive/${PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="amd64 x86"
	S="${WORKDIR}/${MY_P}"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="nls"

RDEPEND="${PYTHON_DEPS}
	dev-libs/libappindicator:3[introspection]
	>=dev-python/pyinotify-0.9.6[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	gnome-extra/zenity
	net-misc/yandex-disk
	x11-misc/xclip
	x11-libs/gtk+:3[introspection]
	x11-libs/gdk-pixbuf:2[introspection]"

DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_prepare() {
	mv todo.txt TODO || die
	mv build/yd-tools/debian/changelog ChangeLog || die

	if use nls; then
		plocale_find_changes "translations" "yandex-disk-indicator_" ".po"
		rm_loc() {
			ebegin "Disable locale: ${1}"
			rm -f translations/yandex-disk-indicator_${1}.{mo,po} || die
			rm -f translations/{actions-,ya-setup-}${1}.lang || die
			eend
		}
		plocale_for_each_disabled_locale_do rm_loc
	else
		for x in ${PLOCALES}; do
			ebegin "Disable locale: ${x}"
			rm -f translations/yandex-disk-indicator_${x}.{mo,po} || die
			rm -f translations/{actions-,ya-setup-}${x}.lang || die
			eend
		done
	fi

	default
}

src_install() {
	if use nls; then
		do_loc() {
			insinto "/usr/share/locale/${1}/LC_MESSAGES"
			newins translations/yandex-disk-indicator_${1}.mo yandex-disk-indicator.mo

			# Remove other excluded translations
			rm -f translations/yandex-disk-indicator_${1}.{mo,po} || die
		}
		plocale_for_each_locale_do do_loc
	fi

	insinto "/usr/share/yd-tools" && exeinto "/usr/share/yd-tools"
	doins -r translations icons fm-actions
	doexe ya-setup

	dodoc README.md TODO ChangeLog
	domenu Yandex.Disk-indicator.desktop
	doman man/yd-tools.1

	python_foreach_impl python_newscript yandex-disk-indicator.py yandex-disk-indicator
}

pkg_postinst() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}
