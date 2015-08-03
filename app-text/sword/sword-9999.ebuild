# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/sword/sword-1.7.3.ebuild,v 1.1 2014/10/14 18:37:32 creffett Exp $

EAPI=5
inherit autotools eutils flag-o-matic subversion

DESCRIPTION="Library for Bible reading software"
HOMEPAGE="http://www.crosswire.org/sword/"
#EGIT_REPO_URI="https://github.com/greg-hellings/sword.git"
ESVN_REPO_URI="http://crosswire.org/svn/sword/trunk"
ESVN_REVISION=3203

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="curl debug doc icu static-libs"

RDEPEND="sys-libs/zlib
	curl? ( net-misc/curl )
	icu? ( dev-libs/icu:= )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

DOCS="AUTHORS CODINGSTYLE ChangeLog README"

RESTRICT="test"	#Restricting for now, see bug 313207

src_prepare() {
	rm include/{zlib.h,zconf.h} || die
	eautoreconf
	sed -i \
		-e '/FLAGS/s:-g3::' -e '/FLAGS/s:-O0::' \
		-e '/FLAGS/s:-O2::' -e '/FLAGS/s:-O3::' \
		configure || die

	sed -i -e '/FLAGS/s:-Werror::' configure || die #408289
	sed -i -e '/^#inc.*curl.*types/d' src/mgr/curl*.cpp || die #378055

	cat <<-EOF > "${T}"/${PN}.conf
	[Install]
	DataPath=${EPREFIX}/usr/share/${PN}/
	EOF
}

src_configure() {
	# TODO: Why is this here and can we remove it?
	strip-flags

	econf \
		$(use_enable static-libs static) \
		$(use_enable debug) \
		--with-zlib \
		$(use_with icu) \
		--with-conf \
		--without-xz \
		--with-bzip2 \
		$(use_with curl)
}

src_install() {
	insinto /usr/include
	doins -r "${S}/include/osisreferencelinks.h"
	default

	find "${ED}" -name '*.la' -exec rm -f {} +

	if use doc; then
		rm -rf examples/.cvsignore
		rm -rf examples/cmdline/.cvsignore
		rm -rf examples/cmdline/.deps
		cp -R samples examples "${ED}"/usr/share/doc/${PF}/
	fi

	insinto /etc
	doins "${T}"/${PN}.conf
}

pkg_postinst() {
	elog "Check out http://www.crosswire.org/sword/modules/"
	elog "to download modules that you would like to use with SWORD."
	elog "Follow module installation instructions found on"
	elog "the web or in ${EROOT}/usr/share/doc/${PF}/"
}
