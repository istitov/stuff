# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils flag-o-matic autotools multilib toolchain-funcs git-r3

DESCRIPTION="alpine is an easy to use text-based based mail and news client"
HOMEPAGE="http://www.washington.edu/alpine/ http://alpine.freeiz.com/alpine/release/"
EGIT_REPO_URI="git://repo.or.cz/alpine.git"

LICENSE="Apache-2.0"
KEYWORDS=""
SLOT="0"
IUSE="doc ipv6 kerberos ldap nls passfile smime spell ssl threads"

DEPEND="sys-libs/pam
	>=net-libs/c-client-2007f-r4
	sys-libs/ncurses:0
	>=dev-libs/openssl-1.0.1c
	ldap? ( net-nds/openldap )
	kerberos? ( app-crypt/mit-krb5 )
	spell? ( app-text/aspell )"
RDEPEND="${DEPEND}
	app-misc/mime-types
	!<=net-mail/uw-imap-2004g"

src_prepare() {
	eautoreconf
}

src_configure() {
	local myconf="--without-tcl
	--with-system-pinerc=/etc/pine.conf
	--with-system-fixed-pinerc=/etc/pine.conf.fixed"
	#--disable-debug"
	# fixme
	#   --with-system-mail-directory=DIR?

	if use ssl; then
		myconf+=" --with-ssl
		--with-ssl-include-dir=/usr/include/openssl
		--with-ssl-lib-dir=/usr/$(get_libdir)
		--with-ssl-certs-dir=/etc/ssl/certs"
	else
		myconf+="--without-ssl"
	fi
	econf \
		$(use_with ldap) \
		$(use_with ssl) \
		$(use_with passfile passfile .pinepwd) \
		$(use_with kerberos krb5) \
		$(use_with threads pthread) \
		$(use_with spell interactive-spellcheck /usr/bin/aspell) \
		$(use_enable nls) \
		$(use_with ipv6) \
		$(use_with smime) \
		${myconf}
}

src_compile() {
	emake AR=$(tc-getAR)
}

src_install() {
	emake DESTDIR="${D}" install
	doman doc/man1/*.1
	dodoc NOTICE README*

	if use doc ; then
		dodoc doc/brochure.txt
		docinto html/tech-notes
		dohtml -r doc/tech-notes/
	fi
}
