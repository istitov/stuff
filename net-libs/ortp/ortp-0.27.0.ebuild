# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit eutils autotools

DESCRIPTION="Open Real-time Transport Protocol (RTP, RFC3550) stack"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="mirror://nongnu/linphone/${PN}/sources/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc examples ipv6 minimal srtp ssl"

RDEPEND="
	net-libs/bctoolbox
	srtp? ( net-libs/libsrtp )
	ssl? ( dev-libs/openssl )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

src_prepare() {
	# respect user's CFLAGS
	sed -i -e "s:-O2::;s: -g::" configure.ac || die "patching configure.ac
	failed"

	# to be sure doc is not builded nor installed w/ -doc and doxygen installed
	if ! use doc; then
		sed -i -e 's/test $DOXYGEN != //' configure \
			|| die "patching configure failed"
	fi

	# to authorize -srtp even with libsrtp installed
	if ! use srtp; then
		sed -i -e 's/$have_srtp_headers$have_srtp_lib//' configure \
			|| die "patching configure failed"
	fi

	# to authorize -ssl even with openssl installed
	if ! use ssl; then
		sed -i -e 's/SSL_LIBS=".*"/SSL_LIBS=""/' \
			-e 's/openssl\/.*.h/poll.h/' configure \
			|| die "patching configure failed"
	fi

	# do not build examples programs, see bug 226247
	sed -i -e 's/SUBDIRS = . tests/SUBDIRS = ./' src/Makefile.in \
		|| die "patching src/Makefile.in failed"

	# ${P} is added after ${docdir}
	if use doc; then
		sed -i -e 's/$(docdir)\/$(PACKAGE)-$(VERSION)/$(docdir)/' Makefile.in \
			|| die "patching Makefile.in failed"
	fi

	# make sure to use host libtool version
	rm -f m4/libtool.m4 m4/lt*.m4 #282268
	mkdir m4
	eautoreconf
}

src_configure() {
	# force docdir to standard Gentoo doc directory
	# memcheck is for HP-UX only
	# mode64bit adds +DA2.0W +DS2.0 CFLAGS wich are needed for HP-UX
	# strict adds -Werror, don't want it
	econf \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--disable-memcheck \
		--disable-mode64bit \
		--disable-strict \
		--enable-fast-install \
		--enable-libtool-lock \
		$(use_enable debug) \
		$(use_enable ipv6) \
		$(use_enable minimal perf)
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc AUTHORS ChangeLog NEWS README TODO

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins src/tests/*.c
	fi
}
