# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Claude Code - an agentic coding tool by Anthropic"
HOMEPAGE="https://claude.com/product/claude-code"

# Temporary overlay copy ahead of ::gentoo. Track `latest`, not the older
# `stable` channel, and drop this package when Gentoo catches up.
# Rechecked 2026-09-11.

# Upstream's installer resolves a manifest and downloads one self-contained binary.
GCS_BUCKET="https://downloads.claude.ai/claude-code-releases"
SRC_URI="
	amd64? (
		elibc_glibc? ( ${GCS_BUCKET}/${PV}/linux-x64/claude -> claude-amd64-glibc-${PV} )
		elibc_musl?  ( ${GCS_BUCKET}/${PV}/linux-x64-musl/claude -> claude-amd64-musl-${PV} )
	)
	arm64? (
		elibc_glibc? ( ${GCS_BUCKET}/${PV}/linux-arm64/claude -> claude-arm64-glibc-${PV} )
		elibc_musl?  ( ${GCS_BUCKET}/${PV}/linux-arm64-musl/claude -> claude-arm64-musl-${PV} )
	)"
S="${WORKDIR}"

# Paid service with clickthrough terms; see HOMEPAGE.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
QA_PREBUILT="opt/bin/claude"

# The Bun binary spawns external ripgrep and bundles no rg asset. PATH-only mode
# cannot enforce Read denies outside the working directory; keep the dependency
# unconditional while USE_BUILTIN_RIPGREP's default is unknown. Other NEEDED
# entries are glibc only. Rechecked against 2.1.268 on 2026-09-11.
RDEPEND="sys-apps/ripgrep"

# Retain Gentoo's documented AVX/AVX2 baseline. AVX-512 code is CPUID-dispatched,
# so its presence does not justify an AVX-512 requirement.
IUSE="cpu_flags_x86_avx cpu_flags_x86_avx2"
REQUIRED_USE="amd64? ( cpu_flags_x86_avx cpu_flags_x86_avx2 )"

RESTRICT="bindist mirror strip"

src_compile() {
	:
}

src_install() {
	# Architecture and libc branches make ${A} a single filename.
	exeinto /opt/bin
	newexe "${DISTDIR}/${A}" claude

	insinto /etc/${PN}
	newins "${FILESDIR}/managed-settings-native.json" managed-settings.json
}

pkg_postinst() {
	if ! grep -q DISABLE_INSTALLATION_CHECKS /etc/claude-code/managed-settings.json; then
		ewarn "Ensure you run etc-update or dispatch-conf before executing claude."
		ewarn "Failure to properly integrate changes to /etc/claude-code/managed-settings.json"
		ewarn "may lead to claude installing itself to your homedir without asking."
	fi
}
