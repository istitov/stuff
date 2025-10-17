# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools

DESCRIPTION="BAMF Application Matching Framework"
HOMEPAGE="https://launchpad.net/bamf"
SRC_URI="http://launchpad.net/${PN}/0.2/0.2.104/+download/${PN}-${PV}.tar.gz"
RESTRICT="primaryuri"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="LGPL-3"
IUSE="+gtk2 gtk3"

DDEPEND=">=dev-lang/vala-0.11.7:=
	gtk3? (
		>=x11-libs/libwnck-3.2.1
		>=x11-libs/gtk+-3.2.1 )
	gnome-base/libgtop"
DEPEND="${DDEPEND}
	dev-util/gtk-doc"

RDEPEND="${DDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
}

src_prepare(){
	default
	sed -i -e 's/vapigen/vapigen-0.12/' configure.in
	sed -i -e 's/-Werror//' configure.in

	if use gtk2; then
		sed -i -e 's/AM_PATH_GTK_3_0/AM_PATH_GTK_2_0/' configure.in
	fi

	eautoreconf
}

src_configure(){
	if use gtk2; then
		econf --with-gtk=2
	fi

	if use gtk3; then
		mkdir gtk3-hack
		cp -R * gtk3-hack
		cd gtk3-hack
		econf --with-gtk=3
	fi
}

src_compile(){
	if use gtk2; then
		emake || die
	fi

	if use gtk3; then
		cd gtk3-hack
		emake || die
	fi
}

src_install() {
	if use gtk2; then
		emake DESTDIR="${ED}" install || die "make install failed"
	fi

	if use gtk3; then
		cd gtk3-hack
		emake DESTDIR="${ED}" install || die "make install failed"
	fi
}
