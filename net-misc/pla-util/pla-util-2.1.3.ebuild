# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Capped by dev-ada/gprbuild, which is itself ADA_COMPAT=( gcc_{15..16} );
# a wider set here would make the BDEPEND below unsolvable.
ADA_COMPAT=( gcc_{15..16} )

inherit ada fcaps multiprocessing shell-completion

DESCRIPTION="Utility for HomePlug AV2 power line adapters with Broadcom chipsets"
HOMEPAGE="https://github.com/serock/pla-util"
SRC_URI="https://github.com/serock/${PN}/archive/refs/tags/${PV}.tar.gz
	-> ${P}.gh.tar.gz"

# Every source file carries "SPDX-License-Identifier: GPL-3.0-or-later" and
# alire.toml says licenses = "GPL-3.0-or-later". GitHub's repo-level label
# reads plain "GPL-3.0"; the file headers are authoritative, so GPL-3+.
LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

REQUIRED_USE="${ADA_REQUIRED_USE}"

# The GNAT runtime is bound statically (see src_compile), so the installed
# binary needs only libpcap at runtime -- not the gcc slot it was built with.
RDEPEND="net-libs/libpcap"
DEPEND="
	${RDEPEND}
	${ADA_DEPS}
"
BDEPEND="
	${ADA_DEPS}
	dev-ada/gprbuild[${ADA_USEDEP}]
"

# pla-util drives the adapter over raw Ethernet (libpcap on an AF_PACKET
# socket), so without cap_net_raw it only works as root -- upstream's README
# tells users to run `filecap /usr/bin/pla-util net_raw` by hand after
# installing. Do it at merge time instead.
FILECAPS=( cap_net_raw usr/bin/${PN} )

# einstalldocs' default list matches a bare CHANGELOG, not CHANGELOG.md.
DOCS=( CHANGELOG.md README.md )

src_compile() {
	# pla_util.gpr reads GNATBINDFLAGS from the environment and defaults it to
	# "-Es -shared", i.e. link against the shared GNAT runtime. That is right
	# on openSUSE (upstream's distro), where libgnat lives in the system
	# libdir, but wrong here: Gentoo installs libgnat-15.so under
	# /usr/lib/gcc/${CHOST}/<slot>/adalib/, and only the parent
	# /usr/lib/gcc/${CHOST}/<slot> is in ld.so.conf. Upstream also ships
	# neither RPATH nor RUNPATH on purpose, so a shared bind yields a binary
	# that dies at exec with
	#   error while loading shared libraries: libgnat-15.so
	# Bind the runtime statically instead. -Es (symbolic tracebacks in
	# exception occurrences) is upstream's, and kept.
	# verified 2026-09-04 on gcc-15.3.1_p20260717[ada] + gprbuild-26.0.0
	local -x GNATBINDFLAGS="-Es -static"

	# LDFLAGS needs no -largs: pla_util.gpr already splices
	# External_As_List("LDFLAGS") into its own Linker switches, and gprbuild
	# resolves project externals from the environment (verified 2026-09-04 --
	# an LDFLAGS-only -Wl,--build-id=none reached the link line).
	# ADAFLAGS does need -cargs, though. The project reads it the same way but
	# then appends its own -O3 -gnatn afterwards, so an ADAFLAGS-supplied -O2
	# would lose. A -cargs section is emitted last of all and therefore wins.
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
