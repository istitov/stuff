# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic toolchain-funcs

MY_COMMIT="234e2dd2bf920e1fdb2deaa4ab549ba85e11e9d7"
DESCRIPTION="A very small C compiler for ix86/amd64"
HOMEPAGE="https://bellard.org/tcc/ https://repo.or.cz/tinycc.git/"

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://repo.or.cz/r/tinycc.git"
	inherit git-r3
elif [[ ${PV} == *_p* ]] ; then
	# The canonical snapshot endpoint serves a JavaScript challenge; use the
	# same immutable Git object from GitHub.
	SRC_URI="https://github.com/TinyCC/tinycc/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/tinycc-${MY_COMMIT}"
else
	SRC_URI="https://download.savannah.gnu.org/releases/tinycc/${P}.tar.bz2"
fi

LICENSE="LGPL-2.1"
SLOT="0"
if [[ ${PV} != *9999* ]] ; then
	KEYWORDS="amd64 ~arm64 ~riscv ~x86"
fi

BDEPEND="dev-lang/perl" # doc generation
IUSE="test"
RESTRICT="!test? ( test )"

src_prepare() {
	default

	# Prevent the upstream install target from stripping.
	sed -i \
		-e 's|$(INSTALL) -s|$(INSTALL)|' \
		-e 's|STRIP_yes = -s|STRIP_yes =|' \
		Makefile || die

	# Make examples directly executable with tcc.
	sed -i -e '1{
		i#! /usr/bin/tcc -run
		/^#!/d
	}' examples/ex*.c || die
	sed -i -e '1s/$/ -lX11/' examples/ex4.c || die

	# Use the installed tcc path (Gentoo bug 888115).
	sed -i -e "s|/usr/local/bin/tcc|/usr/bin/tcc|g" tcc-doc.texi || die

	# Remove unsupported texi2html options.
	sed -i -e 's/-number//' Makefile || die
	sed -i -e 's/--sections//' Makefile || die
}

src_configure() {
	# LTO breaks tests and static archives (Gentoo bugs 866815, 926120).
	filter-lto

	local libc

	# Tests invoke tcc as CC and reject inherited consumer flags.
	use test && unset CFLAGS LDFLAGS

	use elibc_musl && libc=musl

	# This is not an Autoconf script.
	./configure --cc="$(tc-getCC)" \
		${libc:+--config-${libc}} \
		--prefix="${EPREFIX}/usr" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--docdir="${EPREFIX}/usr/share/doc/${PF}"
}

src_compile() {
	emake AR="$(tc-getAR)" LDFLAGS="${LDFLAGS}"
}

src_test() {
	# tcc's linker does not understand consumer as-needed flags.
	TCCFLAGS="" emake test
}

src_install() {
	emake DESTDIR="${D}" install

	dodoc Changelog README TODO VERSION
	exeinto /usr/share/doc/${PF}/examples
	doexe examples/ex*.c
}
