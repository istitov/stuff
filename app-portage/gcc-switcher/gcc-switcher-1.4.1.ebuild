# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Switch gcc's version per package"
HOMEPAGE="https://github.com/megabaks/gcc-switcher"
SRC_URI="https://github.com/megabaks/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="app-shells/bash
		sys-apps/portage"
RDEPEND="${DEPEND}"

src_install(){
	insinto /etc/portage
	doins gcc-switcher
	doins "${FILESDIR}/package.compilers"
	doins "${FILESDIR}/package.compilers-full"
}

pkg_preinst() {
	# Preserve existing user config across reinstalls.
	local f
	for f in package.compilers package.compilers-full; do
		if [[ -f "${EROOT}/etc/portage/${f}" ]]; then
			cp "${EROOT}/etc/portage/${f}" "${D}/etc/portage/${f}" || die
		fi
	done
}

pkg_postinst() {
	if ! grep -q gcc-switcher "${EROOT}/etc/portage/bashrc" 2>/dev/null; then
		elog "Now you need run:"
		elog "echo 'source /etc/portage/gcc-switcher' >> /etc/portage/bashrc"
	fi
}
