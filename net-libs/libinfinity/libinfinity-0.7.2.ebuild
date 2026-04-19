# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

MY_PV=$(ver_cut 1-2)

DESCRIPTION="An implementation of the Infinote protocol written in GObject-based C"
HOMEPAGE="https://gobby.github.io/"
SRC_URI="https://github.com/gobby/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	http://releases.0x539.de/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0.7"
KEYWORDS="~amd64 ~x86"
IUSE="avahi doc +gtk3 server static-libs"

RDEPEND="
	dev-libs/glib:2
	dev-libs/libxml2
	net-libs/gnutls
	net-misc/gsasl
	sys-libs/pam
	avahi? (
		net-dns/avahi
		dev-libs/libdaemon
	)
	gtk3? ( >=x11-libs/gtk+-3.10.0:3 )
	server? (
		acct-user/infinote
		acct-group/infinote
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/gtk-doc
	sys-devel/gettext
	virtual/pkgconfig
"

DOCS=( AUTHORS ChangeLog.manual NEWS README.md TODO )

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable doc gtk-doc) \
		$(use_enable static-libs static) \
		$(use_with gtk3 inftextgtk) \
		$(use_with gtk3 infgtk) \
		$(use_with server infinoted) \
		$(use_with avahi) \
		$(use_with avahi libdaemon)
}

src_install() {
	default
	if use server; then
		newinitd "${FILESDIR}/infinoted.initd" infinoted
		newconfd "${FILESDIR}/infinoted.confd" infinoted

		keepdir /var/lib/infinote
		fowners infinote:infinote /var/lib/infinote
		fperms 770 /var/lib/infinote

		dosym "infinoted-${MY_PV}" "/usr/bin/infinoted"

		elog "Add local users who should have local access to the documents"
		elog "created by infinoted to the infinote group."
		elog "The documents are saved in /var/lib/infinote per default."
	fi
}
