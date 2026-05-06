# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Kokoro-82M TTS server in Rust (CPU; OpenAI-compatible HTTP API)"
HOMEPAGE="https://github.com/lucasjinreal/Kokoros"

# Tracks upstream lucasjinreal/Kokoros directly — the lemonade-sdk fork
# diverges only in CI/release infrastructure + a bundled copy of
# espeak-ng-data (which we already have via app-accessibility/espeak-ng),
# so source-build users get the same binary either way.
EGIT_REPO_URI="https://github.com/lucasjinreal/Kokoros.git"

LICENSE="Apache-2.0"
SLOT="0"
# No KEYWORDS for live ebuild.

# Cargo fetches all crates online; bundled ONNX Runtime download is also part
# of the build via `ort = { default-features = true }`. Keep network open.
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
	# cargo.eclass assumes a vendored CRATES list; we let cargo fetch
	# online via RESTRICT=network-sandbox, so call cargo directly.
	# espeak-rs-sys bundles espeak-ng but its build.rs doesn't emit
	# `cargo:rustc-link-lib=pcaudio`, leaving audio_object_* unresolved
	# at link time. Force the link via RUSTFLAGS.
	local RUSTFLAGS="${RUSTFLAGS} -l pcaudio"
	export RUSTFLAGS

	cargo build --release --bin koko || die "cargo build failed"
}

src_install() {
	dobin target/release/koko
	# espeak-ng-data is provided by app-accessibility/espeak-ng at
	# /usr/share/espeak-ng-data/; espeak-rs picks it up automatically.
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
	elog "espeak-ng phoneme tables come from app-accessibility/espeak-ng."
}
