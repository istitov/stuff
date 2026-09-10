# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Claude Code - an agentic coding tool by Anthropic"
HOMEPAGE="https://claude.com/product/claude-code"

# Imported from ::gentoo (dev-util/claude-code-2.1.241, maintained by
# jayf@gentoo.org) on 2026-09-05 to carry a newer release than the tree.
# ::gentoo tracks the `latest` channel, not `stable` -- as of this writing
# https://downloads.claude.ai/claude-code-releases/stable resolves to 2.1.236,
# which is OLDER than the 2.1.241 in the tree, so `stable` is not the version
# source to check against. Use the `latest` endpoint.
# DROP THIS PACKAGE once ::gentoo catches up; it exists only to be ahead.

# Upstream's official install method is curl|bash: the script resolves the
# current version, fetches a per-version manifest, and downloads a single
# self-contained `claude` binary. There is nothing else in the release.
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

# claude-code needs a paid subscription and carries a clickthrough
# EULA-type license; see HOMEPAGE for the terms.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
QA_PREBUILT="opt/bin/claude"

# Re-audited 2026-09-05 against the installed 2.1.261 amd64/glibc binary, and
# the three load-bearing findings re-checked on 2.1.263 (2026-09-06) and again
# on 2.1.267 (2026-09-10): the DT_NEEDED set is unchanged, the
# external-ripgrep spawn path is still there, and there is still no vendored
# rg asset in the bunfs tree.
#
# ripgrep is a REAL runtime dep, not decoration: the binary is a Bun
# standalone executable that spawns an external ripgrep (`spawn(rgPath, ...)`)
# for its search tool. It carries no vendored copy -- no rg asset in the
# embedded bunfs tree -- and it degrades when rg is only reachable by name:
# "ripgrep was found only by name on PATH, and a search outside the working
# directory cannot apply your Read deny rules in that configuration".
# It does recognise a USE_BUILTIN_RIPGREP env var whose default could not be
# determined by static inspection, so the dep stays unconditional; revisit
# only with evidence from a run, not from strings.
#
# No other runtime dep is missing: the only DT_NEEDED entries are
# librt/libc/ld-linux/libpthread/libdl/libm, all from sys-libs/glibc.
RDEPEND="sys-apps/ripgrep"

# Kept as ::gentoo has it. The binary does contain both AVX2 and AVX-512
# code (2569 ymm vs 21268 zmm instructions), but SIMD in a Bun binary is
# CPUID-dispatched at runtime, so instruction presence is not evidence of a
# hard requirement -- do NOT promote this to an avx512 REQUIRED_USE on that
# basis. The avx/avx2 floor matches Bun's documented x86-64 baseline.
IUSE="cpu_flags_x86_avx cpu_flags_x86_avx2"
REQUIRED_USE="amd64? ( cpu_flags_x86_avx cpu_flags_x86_avx2 )"

RESTRICT="bindist mirror strip"

src_compile() {
	# Nothing to compile -- the distfile is the finished binary.
	:
}

src_install() {
	# Exactly one distfile is fetched: the amd64/arm64 and glibc/musl
	# SRC_URI branches are mutually exclusive, so ${A} holds a single
	# filename.
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
