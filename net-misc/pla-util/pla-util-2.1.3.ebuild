# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Match gprbuild's gcc slots so ADA_USEDEP remains solvable.
ADA_COMPAT=( gcc_{15..16} )

inherit ada fcaps multiprocessing shell-completion

DESCRIPTION="Utility for HomePlug AV2 power line adapters with Broadcom chipsets"
HOMEPAGE="https://github.com/serock/pla-util"
SRC_URI="https://github.com/serock/${PN}/archive/refs/tags/${PV}.tar.gz
	-> ${P}.gh.tar.gz"

# Source SPDX headers and alire.toml specify GPL-3.0-or-later despite GitHub's
# GPL-3.0 label.
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

REQUIRED_USE="${ADA_REQUIRED_USE}"

# Static GNAT binding leaves only libpcap at runtime.
RDEPEND="net-libs/libpcap"
DEPEND="
	${RDEPEND}
	${ADA_DEPS}
"
BDEPEND="
	${ADA_DEPS}
	dev-ada/gprbuild[${ADA_USEDEP}]
"

# Raw Ethernet access needs cap_net_raw or root; apply upstream's recommended
# capability at merge time.
FILECAPS=( cap_net_raw usr/bin/${PN} )

# einstalldocs' default list matches a bare CHANGELOG, not CHANGELOG.md.
DOCS=( CHANGELOG.md README.md )

src_compile() {
	# Upstream's shared GNAT bind cannot find Gentoo's slot-private libgnat and
	# supplies no RPATH. Bind it statically while retaining -Es tracebacks.
	# verified 2026-09-04 with gcc-15.3.1_p20260717[ada] and gprbuild-26.0.0
	local -x GNATBINDFLAGS="-Es -static"

	# The project consumes LDFLAGS directly. Pass ADAFLAGS via final -cargs so
	# they override its later -O3 -gnatn. # verified 2026-09-04
	gprbuild -p -P pla_util.gpr -j$(get_makeopts_jobs) \
		-cargs ${ADAFLAGS} || die "gprbuild failed"
}

src_install() {
	dobin bin/${PN}
	dobashcomp completions/${PN}
	einstalldocs
}

pkg_postinst() {
	fcaps_pkg_postinst

	if ! use filecaps; then
		elog "USE=filecaps is off, so ${PN} carries no cap_net_raw capability"
		elog "and has to be run as root. Otherwise it reports:"
		elog "  ${PN}: You don't have permission to capture on that device"
	fi
}
