# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools git-r3

DESCRIPTION="/etc/portage configuration cleaner and manager (live)"
HOMEPAGE="https://github.com/istitov/portconf"
EGIT_REPO_URI="https://github.com/istitov/portconf.git"

LICENSE="GPL-3+"
SLOT="0"
PROPERTIES="live"
# No KEYWORDS — live ebuilds are unkeyworded by Gentoo convention and
# must be unmasked per-system via package.accept_keywords.
IUSE="+bash-completion +zsh-completion test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=app-shells/bash-4.4:0
	app-admin/eselect
	app-portage/eix
	app-portage/portage-utils
	dev-libs/tre
	sys-apps/portage
	bash-completion? ( app-shells/bash-completion )
"
# Live builds start from a git checkout, not a `make dist` tarball, so
# autoconf + automake are needed to generate configure / Makefile.in.
# Test BDEPEND also mirrors RDEPEND so the integration tier gets its
# runtime tools guaranteed-installed-before-build (see release ebuild).
BDEPEND="
	dev-build/autoconf
	dev-build/automake
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

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable bash-completion) \
		$(use_enable zsh-completion)
}

src_test() {
	bats tests/unit/ || die "bats unit tests failed"

	# See release ebuild for the eix-cache rationale.
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
