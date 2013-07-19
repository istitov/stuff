# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/psi/psi-9999.ebuild,v 1.12 2011/06/30 09:23:16 pva Exp $

EAPI="4"

LANGS="ar be bg br ca cs da de ee el eo es et fi fr hr hu it ja mk nl pl pt pt_BR ru se sk sl sr sr@latin sv sw uk ur_PK vi zh_CN zh_TW"

EGIT_HAS_SUBMODULES=1
PSI_URI="git://github.com/psi-im"
PSI_PLUS_URI="git://github.com/psi-plus"
EGIT_REPO_URI="${PSI_URI}/psi.git"
PSI_LANGS_URI="${PSI_URI}/psi-translations.git"
PSI_PLUS_LANGS_URI="${PSI_PLUS_URI}/psi-plus-l10n.git"

inherit eutils qt4-r2 multilib git-2

DESCRIPTION="Qt4 Jabber client, with Licq-like interface"
HOMEPAGE="http://psi-im.org/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="crypt dbus debug doc enchant extras jingle iconsets spell ssl xscreensaver powersave
plugins whiteboarding webkit"

REQUIRED_USE="
	iconsets? ( extras )
	plugins? ( extras )
	powersave? ( extras )
	webkit? ( extras )
"

RDEPEND="
	|| ( ~dev-qt/qtgui-4.8.4:4[dbus?] >=dev-qt/qtgui-4.8.5:4 )
	>=app-crypt/qca-2.0.2:2
	|| ( >=sys-libs/zlib-1.2.5.1-r2[minizip] <sys-libs/zlib-1.2.5.1-r1 )
	whiteboarding? ( dev-qt/qtsvg:4 )
	spell? (
		enchant? ( >=app-text/enchant-1.3.0 )
		!enchant? ( app-text/aspell )
	)
	xscreensaver? ( x11-libs/libXScrnSaver )
	extras? ( webkit? ( dev-qt/qtwebkit:4 ) )
"
DEPEND="${RDEPEND}
	extras? (
		sys-devel/qconf
	)
	doc? ( app-doc/doxygen )
	virtual/pkgconfig
"
PDEPEND="
	crypt? ( app-crypt/qca-gnupg:2 )
	jingle? (
		net-im/psimedia[extras?]
		app-crypt/qca-ossl:2
	)
	ssl? ( app-crypt/qca-ossl:2 )
"
RESTRICT="test"

pkg_setup() {
	MY_PN=psi
	if use extras; then
		MY_PN=psi-plus
		echo
		ewarn "You're about to build heavily patched version of Psi called Psi+."
		ewarn "It has really nice features but still is under heavy development."
		ewarn "Take a look at homepage for more info: http://code.google.com/p/psi-dev"
		echo

		if use iconsets; then
			echo
			ewarn "Some artwork is from open source projects, but some is provided 'as-is'"
			ewarn "and has not clear licensing."
			ewarn "Possibly this build is not redistributable in some countries."
		fi
	fi
}

src_unpack() {
	git-2_src_unpack
	unset EGIT_HAS_SUBMODULES EGIT_NONBARE

	# fetch translations
	unset EGIT_MASTER EGIT_BRANCH EGIT_COMMIT EGIT_PROJECT
	if use extras; then
		EGIT_REPO_URI="${PSI_PLUS_LANGS_URI}"
	else
		EGIT_REPO_URI="${PSI_LANGS_URI}"
	fi
	EGIT_SOURCEDIR="${WORKDIR}/psi-l10n"
	git-2_src_unpack

	if use extras; then
		unset EGIT_MASTER EGIT_BRANCH EGIT_COMMIT EGIT_PROJECT
		EGIT_PROJECT="psi-plus/main.git" \
		EGIT_SOURCEDIR="${WORKDIR}/psi-plus" \
		EGIT_REPO_URI="${PSI_PLUS_URI}/main.git" \
		git-2_src_unpack

		if use iconsets; then
			unset EGIT_MASTER EGIT_BRANCH EGIT_COMMIT EGIT_PROJECT
			EGIT_PROJECT="psi-plus/resources.git" \
			EGIT_SOURCEDIR="${WORKDIR}/resources" \
			EGIT_REPO_URI="${PSI_PLUS_URI}/resources.git" \
			git-2_src_unpack
		fi
	fi
}

src_prepare() {
	if use extras; then
		cp -a "${WORKDIR}/psi-plus/iconsets" "${S}" || die
		if use iconsets; then
			cp -a "${WORKDIR}/resources/iconsets" "${S}" || die
		fi

		EPATCH_SOURCE="${WORKDIR}/psi-plus/patches/" EPATCH_SUFFIX="diff" EPATCH_FORCE="yes" epatch

		use powersave && epatch "${WORKDIR}/psi-plus/patches/dev/psi-reduce-power-consumption.patch"

		PSI_PLUS_REVISION="$(cd "${WORKDIR}/psi-plus" && git describe --tags|cut -d - -f 2)"
		use webkit && {
			echo "0.16.${PSI_PLUS_REVISION}-webkit (@@DATE@@)" > version
		} || {
			echo "0.16.${PSI_PLUS_REVISION} (@@DATE@@)" > version
		}

		qconf || die "Failed to create ./configure."
	fi

	rm -rf third-party/qca # We use system libraries. Remove after patching, some patches may affect qca.
}

src_configure() {
	# unable to use econf because of non-standard configure script
	# disable growl as it is a MacOS X extension only
	local myconf="
		--disable-growl
		--no-separate-debug-info
	"
	use dbus || myconf+=" --disable-qdbus"
	use debug && myconf+=" --debug"
	if use spell; then
		if use enchant; then
			myconf+=" --disable-aspell"
		else
			myconf+=" --disable-enchant"
		fi
	else
		myconf+=" --disable-aspell --disable-enchant"
	fi
	use whiteboarding && myconf+=" --enable-whiteboarding"
	use xscreensaver || myconf+=" --disable-xss"
	if use extras; then
		use plugins && myconf+=" --enable-plugins"
		use webkit && myconf+=" --enable-webkit"
	fi

	./configure \
		--prefix="${EPREFIX}"/usr \
		--qtdir="${EPREFIX}"/usr \
		${myconf} || die

	eqmake4
}

src_compile() {
	emake

	if use doc; then
		cd doc
		make api_public || die "make api_public failed"
	fi
}

src_install() {
	emake INSTALL_ROOT="${D}" install

	# this way the docs will be installed in the standard gentoo dir
	rm -f "${ED}"/usr/share/${MY_PN}/{COPYING,README}
	newdoc iconsets/roster/README README.roster
	newdoc iconsets/system/README README.system
	newdoc certs/README README.certs
	dodoc README

	if use extras && use plugins; then
		insinto /usr/share/${MY_PN}/plugins
		doins src/plugins/plugins.pri
		doins src/plugins/psiplugin.pri
		doins -r src/plugins/include
		sed -i -e "s:target.path.*:target.path = /usr/$(get_libdir)/${MY_PN}/plugins:" \
			"${ED}"/usr/share/${MY_PN}/plugins/psiplugin.pri \
			|| die "sed failed"
	fi

	use doc && dohtml -r doc/api

	# install translations
	cd "${WORKDIR}/psi-l10n"
	insinto /usr/share/${MY_PN}
	for x in ${LANGS}; do
		if use linguas_${x}; then
			if use extras; then
				lrelease "translations/${PN}_${x}.ts" || die "lrelease ${x} failed"
				doins "translations/${PN}_${x}.qm"
			else
				lrelease "${x}/${PN}_${x}.ts" || die "lrelease ${x} failed"
				doins "${x}/${PN}_${x}.qm"
			fi
		fi
	done
}
