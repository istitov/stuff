# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3 out-of-source

DESCRIPTION="A free, cross-platform, hardware independent AdLib sound player library"
HOMEPAGE="https://adplug.github.io/"
EGIT_REPO_URI="https://github.com/adplug/${PN}.git"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="debug static-libs"

RDEPEND=">=dev-cpp/libbinio-1.4"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf
}

my_src_configure() {
	# Real OPL output drives ISA ports with inb/outb, which only exist on x86;
	# musl's <sys/io.h> lacks them elsewhere. Take the no-hardware path there.
	if ! use amd64 && ! use x86; then
		local -x ac_cv_header_sys_io_h=no
	fi

	econf \
		$(use_enable debug) \
		$(use_enable static-libs static)
}

my_src_install_all() {
	einstalldocs
	find "${ED}" -name '*.la' -delete || die
}
