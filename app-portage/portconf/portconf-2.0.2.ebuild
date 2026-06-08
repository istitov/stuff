# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="/etc/portage configuration cleaner and manager"
HOMEPAGE="https://github.com/istitov/portconf"
SRC_URI="https://github.com/istitov/portconf/releases/download/${PV}/${P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+bash-completion +zsh-completion test"
RESTRICT="!test? ( test )"

# Runtime deps reflect the tools every dispatch arm reaches for:
#   eix          — USE-flag / package metadata lookups
#   portage-utils — qatom (atom parsing), qlist (installed-packages)
#   tre          — agrep (fuzzy use-flag suggestion in invalid_uses)
#   portage      — emerge for backup / restore / overlays
#   eselect      — eselect profile / repository (overlay prune,
#                  profile probes); pulled in transitively by portage
#                  but called directly, so declared explicitly
RDEPEND="
	>=app-shells/bash-4.4:0
	app-admin/eselect
	app-portage/eix
	app-portage/portage-utils
	dev-libs/tre
	sys-apps/portage
	bash-completion? ( app-shells/bash-completion )
"
# Test BDEPEND mirrors RDEPEND for the binaries the integration tier
# actually invokes — duplicate-but-explicit so the test phase gets the
# guaranteed-installed-before-build ordering BDEPEND provides (RDEPEND
# is only guaranteed at install time).
BDEPEND="
	test? (
		dev-util/bats
		dev-util/bats-assert
		dev-util/bats-support
		app-admin/eselect
		app-portage/eix
		app-portage/portage-utils
		dev-libs/tre
		sys-apps/portage
	)
"

DOCS=( ChangeLog README.md INSTALL )

src_configure() {
	econf \
		$(use_enable bash-completion) \
		$(use_enable zsh-completion)
}

src_test() {
	bats tests/unit/ || die "bats unit tests failed"

	# A few integration tests (invalid_uses_make, parts of invalid_uses)
	# need a populated eix cache.  Probe with a real query; if eix has no
	# data, integration is unreliable — emit a clear hint and continue
	# with the rest.
	if ! eix -qe sys-apps/portage >/dev/null 2>&1; then
		ewarn "eix cache is empty or stale on this system."
		ewarn "Run \`eix-update\` as root before re-running tests."
		ewarn "Skipping integration tier — would fail without a cache."
	else
		bats tests/integration/ \
			|| die "bats integration tests failed — if eix-cache-related, run \`eix-update\` and retry"
	fi
}

pkg_postinst() {
	elog "portconf shells out to eix at runtime.  Keep the eix cache"
	elog "current with:"
	elog ""
	elog "    eix-update"
	elog ""
	elog "Or always pass --regen-cache (-rc) to portconf to build a"
	elog "throwaway cache per run:"
	elog ""
	elog "    portconf -rc --use-full      # or any other -rc combination"
	elog ""
	elog "See \`man portconf\` for the full option set."
}
