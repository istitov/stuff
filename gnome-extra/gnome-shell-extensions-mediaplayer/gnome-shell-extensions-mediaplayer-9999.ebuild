# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit autotools git-2 gnome2

DESCRIPTION="A mediaplayer indicator for the gnome-shell."
HOMEPAGE="https://extensions.gnome.org/extension/55/media-player-indicator/"
SRC_URI=""
EGIT_REPO_URI="git://github.com/eonpatapon/gnome-shell-extensions-mediaplayer.git"
#EGIT_BRANCH="gnome-shell-3.0"
#EGIT_BRANCH="gnome-shell-3.2"
#EGIT_BRANCH="gnome-shell-3.8"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

LANGS="de es fr gl he it lt nl pl pt_BR ru tr zh_CN zh_TW"
for X in ${LANGS} ; do
        IUSE+=" linguas_${X}"
done

COMMON_DEPEND="
	>=dev-libs/glib-2.26
	>=gnome-base/gnome-desktop-2.91.6:3[introspection]
	>=app-admin/eselect-gnome-shell-extensions-20111211"
RDEPEND="${COMMON_DEPEND}
	>=dev-libs/gjs-1.29
	dev-libs/gobject-introspection
	>=gnome-base/gnome-shell-3.2
	media-libs/clutter:1.0[introspection]
	net-libs/telepathy-glib[introspection]
	x11-libs/gtk+:3[introspection]
	x11-libs/pango[introspection]"
DEPEND="${COMMON_DEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.26
	gnome-base/gnome-common"

DOCS="COPYING README.md"

src_unpack() {
	echo `pwd`
	git-2_src_unpack
}

src_prepare() {
	eautoreconf
	gnome2_src_prepare

	local lang
        for lang in ${LANGS}; do
                if ! use linguas_${lang}; then
                        rm po/${lang}.po || die "failed to remove nls"
                fi
        done
}

pkg_postinst() {
	gnome2_pkg_postinst

	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?

	elog ""
	elog "Selected master branch which work with Gnome Shell 3.10 up to 3.14."
	elog "Change branch in ebuid file if You use Gnome Shell < 3.10:"
	elog "gnome-shell-3.0, gnome-shell-3.2, gnome-shell-3.8 (for g-s 3.4 up to 3.8)"
	elog "For this simply unmask the appropriate line EGIT_BRANCH"
}
