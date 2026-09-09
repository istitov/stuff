# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV=${PV//./-}
VGMSTREAM_COMMIT="301d49bdd492aaa326e6411710ba7270c36795a9"

DESCRIPTION="A DeaDBeeF plugin for playing streaming video game music using vgmstream"
HOMEPAGE="https://github.com/jchv/deadbeef-vgmstream"
SRC_URI="
	https://github.com/jchv/deadbeef-vgmstream/archive/refs/tags/${MY_PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/vgmstream/vgmstream/archive/${VGMSTREAM_COMMIT}.tar.gz
		-> ${P}-vgmstream.tar.gz
"
S="${WORKDIR}/deadbeef-vgmstream-${MY_PV}"

LICENSE="vgmstream"
SLOT="0"
KEYWORDS="~arm64"

DEPEND_COMMON="
	media-sound/deadbeef
	media-libs/libvorbis
	media-sound/mpg123
	media-video/ffmpeg
"

RDEPEND="${DEPEND_COMMON}"
DEPEND="${DEPEND_COMMON}"

src_unpack() {
	default
	rm -rf "${S}/vgmstream" || die
	mv "${WORKDIR}/vgmstream-${VGMSTREAM_COMMIT}" "${S}/vgmstream" || die
}

src_prepare() {
	sed \
		-e "s|-I\$(DEADBEEF_ROOT)/include|-I/usr/include/deadbeef|" \
		-e "s|-I\$(DEADBEEF_ROOT)/lib|-I/usr/$(get_libdir)/deadbeef|" \
		-i Makefile || die "sed fail"
	default
}

src_compile() {
	# The bundled vgmstream sources link into a shared object, so every
	# TU needs -fPIC; upstream's Makefile doesn't force it and binutils
	# rejects the final link without it. # verified 2026-07-06
	emake CFLAGS="${CFLAGS} -fPIC"
}

src_install() {
	exeinto /usr/$(get_libdir)/deadbeef
	doexe vgm.so
}
