# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="2"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils wxwidgets autotools

MY_P="XaraLX-${PV/_p/r}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Vector graphics editing program"
HOMEPAGE="http://www.xaraxtreme.org/"
SRC_URI="http://downloads2.xara.com/opensource/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"

IUSE="-debug -static +xarlib +filters international"

RDEPEND=">=sys-devel/gcc-3.4.0
	virtual/libintl
	x11-libs/gtk+
	>=x11-libs/wxGTK-2.8.10
	>=sys-devel/gettext-0.14.3
	>=sys-devel/automake-1.6
	>=sys-devel/autoconf-2.59
	media-libs/libpng:1.4
	>=media-libs/jpeg-6b
	app-arch/zip
	dev-lang/perl
	>=dev-libs/libxml2-2.6.0"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/libtool"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	epatch "${FILESDIR}/xaralx-0.7_p1785-wxGTK-2.8.patch"
	sed -i '/info_ptr->trans/s:trans:trans_alpha:' wxOil/outptpng.cpp
	AT_M4DIR=". ${S}/m4" eautoreconf
}

pkg_setup() {
	export WX_GTK_VER="2.8"
	need-wxwidgets unicode
}

src_configure() {
	local myconf
	myconf="$(use_enable debug) $(use_enable static static-exec) \
	$(use_enable xarlib) $(use_enable filters) $(use_enable international)"
	econf --with-wx-config="${WX_CONFIG}" \
	--with-wx-base-config=$"{WX_CONFIG}" \
	${myconf} || die "econf failed"
}

src_compile() {
	emake	||	die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die
	insinto /usr/share/${PN}
	doins -r {Text,}Designs Templates testfiles

	doicon ${PN}.png
	make_desktop_entry XaraLX "Xara LX" xaralx.png "Graphics" || die

	insinto /usr/share/icons/hicolor/48x48/mimetypes
	newins xaralx.png gnome-mime-application-vnd.xara.png
	insinto /usr/share/mime/packages
	doins Mime/xaralx.xml
	insinto /usr/share/application-registry
	doins Mime/mime-storage/gnome/xaralx.applications
	insinto /usr/share/mime-info
	doins Mime/mime-storage/gnome/xaralx.{keys,mime}

	doman doc/xaralx.1
	dodoc AUTHORS ChangeLog LICENSE NEWS README \
		doc/{gifutil.txt,mtrand.txt,XSVG.txt}
	newdoc doc/en/LICENSE LICENSE-docs
	dodir /usr/share/doc/${PF}/html
	tar xzf doc/en/xaralxHelp.tar.gz -C "${D}"/usr/share/doc/${PF}/html
}
