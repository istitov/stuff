# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Kokoro-82M TTS server in Rust (CPU; OpenAI-compatible HTTP API)"
HOMEPAGE="https://github.com/lucasjinreal/Kokoros"

# Track upstream instead of lemonade-sdk's CI/release fork; the wrapper below
# makes system espeak-ng-data discoverable without its bundled copy.
EGIT_REPO_URI="https://github.com/lucasjinreal/Kokoros.git"

LICENSE="Apache-2.0"
SLOT="0"
# Cargo and default-feature ONNX Runtime fetch during the build.
PROPERTIES="live"
RESTRICT="network-sandbox"

# Edition 2024 needs rust >= 1.85; Cargo.toml workspace pins ort 2.0-rc11 etc.
BDEPEND="
	|| ( >=dev-lang/rust-1.85 >=dev-lang/rust-bin-1.85 )
	virtual/pkgconfig
"
RDEPEND="
	app-accessibility/espeak-ng
	media-libs/libogg:=
	media-libs/opus:=
	media-libs/pcaudiolib
	media-libs/sonic
	media-sound/lame:=
"
DEPEND="${RDEPEND}"

src_compile() {
	# The live crate graph is not vendored, so call cargo directly. Vendored
	# espeak-ng omits its pcaudio link directive; supply it explicitly.
	local RUSTFLAGS="${RUSTFLAGS} -l pcaudio"
	export RUSTFLAGS

	cargo build --release --bin koko || die "cargo build failed"
}

src_install() {
	# Vendored espeak-ng bakes its temporary $OUT_DIR data path into koko.
	# After merge, synthesis silently returns a fixed ~0.48 s WAV and status 0.
	# espeak-rs-sys exposes no data-path or system-library build control, so a
	# wrapper sets the first runtime lookup hook for Lemonade and direct users.
	# Validate rather than default: Lemonade exports a bundle-relative path that
	# is invalid for distro installs; preserve only overrides containing phontab.
	# verified 2026-07-28
	exeinto /usr/libexec/${PN}
	doexe target/release/koko

	newbin - koko <<-EOF
		#!/bin/sh
		# Accept both espeak-ng lookup layouts; otherwise use system data.
		if [ ! -f "\${ESPEAK_DATA_PATH}/espeak-ng-data/phontab" ] &&
		   [ ! -f "\${ESPEAK_DATA_PATH}/phontab" ]; then
			ESPEAK_DATA_PATH=/usr/share
		fi
		export ESPEAK_DATA_PATH
		exec /usr/libexec/${PN}/koko "\$@"
	EOF
}

pkg_postinst() {
	elog ""
	elog "Kokoros installed.  Binary: /usr/bin/koko"
	elog ""
	elog "Model + voice files are NOT shipped with this ebuild — they total"
	elog "~330 MB and need to be downloaded from HuggingFace before first use."
	elog ""
	elog "Quickest path: drop them into ~/.cache/kokoros/ (or any dir):"
	elog "  mkdir -p ~/.cache/kokoros/checkpoints ~/.cache/kokoros/data"
	elog "  curl -L -o ~/.cache/kokoros/checkpoints/kokoro-v1.0.onnx \\"
	elog "    https://github.com/nazdridoy/kokoro-tts/releases/download/v1.0.0/kokoro-v1.0.onnx"
	elog "  curl -L -o ~/.cache/kokoros/data/voices-v1.0.bin \\"
	elog "    https://github.com/nazdridoy/kokoro-tts/releases/download/v1.0.0/voices-v1.0.bin"
	elog ""
	elog "Then run from that directory, or pass --model / --voices-bin paths."
	elog ""
	elog "/usr/bin/koko is a wrapper that sets ESPEAK_DATA_PATH=/usr/share so"
	elog "the phoneme tables from app-accessibility/espeak-ng are found. The"
	elog "real binary is /usr/libexec/${PN}/koko; calling it directly without"
	elog "that variable produces a fixed ~0.5s stub for any input, silently"
	elog "and with exit status 0."
}
