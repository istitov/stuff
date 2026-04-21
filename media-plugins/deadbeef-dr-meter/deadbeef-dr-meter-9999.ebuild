# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Dynamic Range meter plugin for the DeaDBeeF audio player"
HOMEPAGE="https://github.com/dakeryas/deadbeef-dr-meter"
EGIT_REPO_URI="https://github.com/dakeryas/deadbeef-dr-meter.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE="+gtk3 gtk2"
REQUIRED_USE="|| ( gtk2 gtk3 )"

DEPEND="
	media-sound/deadbeef
	gtk2? ( x11-libs/gtk+:2 )
	gtk3? ( x11-libs/gtk+:3 )
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_compile() {
	emake PREFIX="${EPREFIX}/usr/$(get_libdir)/deadbeef" \
		-C dr_meter
	emake PREFIX="${EPREFIX}/usr/$(get_libdir)/deadbeef" \
		DRMETER_DIR="${S}/dr_meter" -C dr_plugin
	if use gtk2; then
		emake PREFIX="${EPREFIX}/usr/$(get_libdir)/deadbeef" \
			DRMETER_DIR="${S}/dr_meter" GTK=2 -C dr_plugin_gui
	fi
	if use gtk3; then
		emake PREFIX="${EPREFIX}/usr/$(get_libdir)/deadbeef" \
			DRMETER_DIR="${S}/dr_meter" GTK=3 -C dr_plugin_gui
	fi
}

src_install() {
	# The libdrmeter shared lib lives next to the plugin so deadbeef
	# can find it without polluting /usr/lib64.
	exeinto /usr/$(get_libdir)/deadbeef
	doexe dr_meter/lib/libdrmeter.so* dr_plugin/ddb_dr_meter.so
	use gtk2 && doexe dr_plugin_gui/ddb_dr_meter_gtk2.so
	use gtk3 && doexe dr_plugin_gui/ddb_dr_meter_gtk3.so
}
