# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Use gentoo-zh-drafts' crate tarball: 1,218 CRATES entries exceed pkgcheck's
# 300-entry limit. Audit its workflow at
# https://github.com/gentoo-zh-drafts/codex/blob/crate-dist/.github/workflows/crates.yml
# Treat this third-party artifact as untrusted: its checksum files authenticate
# packages but have empty file maps; Manifest pins only the received archive.
# Verify every bump byte-for-byte against crates.io:
#   tar xJf "${DISTDIR}"/codex-rust-v${PV}-crates.tar.xz -C /tmp/cx
#   ../bin/verify-crate-tarball.py \
#       <src>/codex-rs/Cargo.lock /tmp/cx/cargo_home/gentoo
# 0.153.4: all 1,218 crates and the Cargo.lock set matched. GIT_CRATES and
# RUSTY_V8_TAG=150.4.0 were re-derived from the lock/upstream script.
# verified 2026-09-05
# pycargoebuild rejects workspace roots; self-hosting 127 MiB per release is
# disproportionate. Revisit if verification fails or the publisher disappears.

CRATES="
"

declare -A GIT_CRATES=(
	[appcontainer_common]='https://github.com/microsoft/mxc;6cd3d58f05d3447e67109cfb75e042803b843ca4;mxc-%commit%/src/backends/appcontainer/common'
	[learning_mode_core]='https://github.com/microsoft/mxc;6cd3d58f05d3447e67109cfb75e042803b843ca4;mxc-%commit%/src/core/learning_mode_core'
	[learning_mode_windows]='https://github.com/microsoft/mxc;6cd3d58f05d3447e67109cfb75e042803b843ca4;mxc-%commit%/src/backends/learning_mode/windows'
	[mxc_config_contract]='https://github.com/microsoft/mxc;6cd3d58f05d3447e67109cfb75e042803b843ca4;mxc-%commit%/src/core/mxc_config_contract'
	[mxc_telemetry]='https://github.com/microsoft/mxc;6cd3d58f05d3447e67109cfb75e042803b843ca4;mxc-%commit%/src/mxc_telemetry'
	[process_security_environment_spec]='https://github.com/microsoft/mxc;6cd3d58f05d3447e67109cfb75e042803b843ca4;mxc-%commit%/src/core/generated/process_security_environment_specification'
	[sandbox_spec]='https://github.com/microsoft/mxc;6cd3d58f05d3447e67109cfb75e042803b843ca4;mxc-%commit%/src/core/generated/base_container_specification'
	[wxc_common]='https://github.com/microsoft/mxc;6cd3d58f05d3447e67109cfb75e042803b843ca4;mxc-%commit%/src/core/wxc_common'
	[crossterm]='https://github.com/openai-oss-forks/crossterm;45fecb9508105988f42fe6ff0441783ed3717f92;crossterm-%commit%'
	[nucleo-matcher]='https://github.com/helix-editor/nucleo;4253de9faabb4e5c6d81d946a5e35a90f87347ee;nucleo-%commit%/matcher'
	[nucleo]='https://github.com/helix-editor/nucleo;4253de9faabb4e5c6d81d946a5e35a90f87347ee;nucleo-%commit%'
	[runfiles]='https://github.com/dzbarsky/rules_rust;b56cbaa8465e74127f1ea216f813cd377295ad81;rules_rust-%commit%/rust/runfiles'
	[tokio-tungstenite]='https://github.com/openai-oss-forks/tokio-tungstenite;0e5b2d73aa18dd9f0a50ee9ff199d5aef7594186;tokio-tungstenite-%commit%'
	[tungstenite]='https://github.com/openai-oss-forks/tungstenite-rs;4fffad30fe373adbdcffab9545e9e9bf4f2fc19f;tungstenite-rs-%commit%'
)

RUST_MIN_VER="1.95.0"

# python3 .github/scripts/rusty_v8_bazel.py resolved-v8-crate-version
RUSTY_V8_TAG="150.4.0"

inherit cargo check-reqs multiprocessing toolchain-funcs

CHECKREQS_MEMORY="15G"
CHECKREQS_DISK_BUILD="20G"

DESCRIPTION="Codex CLI - OpenAI's AI-powered coding agent"
HOMEPAGE="https://github.com/openai/codex"

SRC_URI="
	https://github.com/openai/${PN}/archive/rust-v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/gentoo-zh-drafts/codex/releases/download/rust-v${PV}/codex-rust-v${PV}-crates.tar.xz
	amd64? (
		https://github.com/openai/codex/releases/download/rusty-v8-v${RUSTY_V8_TAG}/librusty_v8_release_x86_64-unknown-linux-musl.a.gz
			-> rusty_v8_${RUSTY_V8_TAG}_librusty_v8_release_x86_64-unknown-linux-musl.a.gz
		https://github.com/openai/codex/releases/download/rusty-v8-v${RUSTY_V8_TAG}/src_binding_release_x86_64-unknown-linux-musl.rs
			-> rusty_v8_${RUSTY_V8_TAG}_src_binding_release_x86_64-unknown-linux-musl.rs
	)
	arm64? (
		https://github.com/openai/codex/releases/download/rusty-v8-v${RUSTY_V8_TAG}/librusty_v8_release_aarch64-unknown-linux-musl.a.gz
			-> rusty_v8_${RUSTY_V8_TAG}_librusty_v8_release_aarch64-unknown-linux-musl.a.gz
		https://github.com/openai/codex/releases/download/rusty-v8-v${RUSTY_V8_TAG}/src_binding_release_aarch64-unknown-linux-musl.rs
			-> rusty_v8_${RUSTY_V8_TAG}_src_binding_release_aarch64-unknown-linux-musl.rs
	)
	${CARGO_CRATE_URIS}
"

S="${WORKDIR}/${PN}-rust-v${PV}/codex-rs"

LICENSE="Apache-2.0"
# Crate licenses.
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CC0-1.0 CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
# ring conflicts with system OpenSSL in tests.
RESTRICT="test"

DEPEND="
	app-arch/xz-utils:=
	dev-libs/openssl:=
	sys-apps/dbus
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

# Rust ignores make.conf flags.
QA_FLAGS_IGNORED="usr/bin/${PN}"

pkg_pretend() {
	check-reqs_pkg_pretend
}

pkg_setup() {
	check-reqs_pkg_setup
	rust_pkg_setup
	if tc-is-lto; then
		export CARGO_PROFILE_RELEASE_LTO=thin
	else
		export CARGO_PROFILE_RELEASE_LTO=false
	fi
}

gen_git_crate_dir() {
	# Mirror cargo.eclass git-crate path resolution.
	IFS=';' read -r crate_uri commit crate_dir <<<"${GIT_CRATES[$1]}"
	echo "${WORKDIR}/${crate_dir//%commit%/${commit}}"
}

src_prepare() {
	default

	# Redirect nested git dependencies to prestaged paths.
	sed -i '/^\[dependencies\.tungstenite\]/,/^$/{
		s|git = "https://github.com/openai-oss-forks/tungstenite-rs"|path = "'"$(gen_git_crate_dir tungstenite)"'"|
		/^rev = /d
	}' "$(gen_git_crate_dir tokio-tungstenite)/Cargo.toml" || die

	sed -i '/^\[patch\.crates-io\]/,/^$/d' "${S}/Cargo.toml" || die
	sed -i '/^\[patch\."ssh:\/\/git@github\.com/,/^$/d' "${S}/Cargo.toml" || die

	cat >> "${S}/Cargo.toml" <<-EOF || die

	[patch.crates-io]
	crossterm = { path = "$(gen_git_crate_dir crossterm)" }
	tokio-tungstenite = { path = "$(gen_git_crate_dir tokio-tungstenite)" }
	tungstenite = { path = "$(gen_git_crate_dir tungstenite)" }
	EOF
}

src_compile() {
	local rusty_v8_triple
	use amd64 && rusty_v8_triple=x86_64-unknown-linux-musl
	use arm64 && rusty_v8_triple=aarch64-unknown-linux-musl

	# codex-core trait resolution overflows rustc's default 8MiB stack
	export RUST_MIN_STACK=16777216

	# Codegen peaks near 5 GiB per rustc; total-RAM CHECKREQS does not constrain
	# parallelism, so cap jobs to prevent late OOMs.
	local rustc_gib=5 memtotal_gib memjobs
	memtotal_gib=$(($(awk '/^MemTotal:/{print $2}' /proc/meminfo) / 1048576))
	memjobs=$(( memtotal_gib / rustc_gib ))
	(( memjobs < 1 )) && memjobs=1
	if (( $(makeopts_jobs) > memjobs )); then
		einfo "Capping rustc jobs $(makeopts_jobs) -> ${memjobs} to fit ${memtotal_gib} GiB RAM (~${rustc_gib} GiB/rustc)"
		local -x MAKEOPTS="-j${memjobs}"
	fi

	RUSTY_V8_ARCHIVE="${DISTDIR}/rusty_v8_${RUSTY_V8_TAG}_librusty_v8_release_${rusty_v8_triple}.a.gz" \
	RUSTY_V8_SRC_BINDING_PATH="${DISTDIR}/rusty_v8_${RUSTY_V8_TAG}_src_binding_release_${rusty_v8_triple}.rs" \
		cargo_src_compile \
			--bin codex \
			--bin codex-code-mode-host
}

src_install() {
	dobin "$(cargo_target_dir)/codex"
	dobin "$(cargo_target_dir)/codex-code-mode-host"
	einstalldocs
}
