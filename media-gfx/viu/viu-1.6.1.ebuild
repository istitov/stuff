# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler2@2.0.1
	aligned-vec@0.6.4
	aligned@0.4.3
	ansi_colours@1.2.3
	anstream@0.6.21
	anstyle-parse@0.2.7
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.13
	anyhow@1.0.100
	arbitrary@1.4.2
	arg_enum_proc_macro@0.3.4
	arrayvec@0.7.6
	as-slice@0.2.1
	autocfg@1.5.0
	autotools@0.2.7
	av-scenechange@0.14.1
	av1-grain@0.2.5
	avif-serialize@0.8.6
	base64@0.22.1
	bit_field@0.10.3
	bitflags@2.10.0
	bitstream-io@4.9.0
	block2@0.6.2
	built@0.8.0
	bumpalo@3.19.0
	bytemuck@1.24.0
	byteorder-lite@0.1.0
	cc@1.2.49
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	clap@4.5.53
	clap_builder@4.5.53
	clap_lex@0.7.6
	color_quant@1.1.0
	colorchoice@1.0.4
	console@0.16.1
	core2@0.4.0
	crc32fast@1.5.0
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	crossterm@0.29.0
	crossterm_winapi@0.9.1
	crunchy@0.2.4
	ctrlc@3.5.1
	dispatch2@0.3.0
	document-features@0.2.12
	either@1.15.0
	encode_unicode@1.0.0
	equator-macro@0.4.2
	equator@0.4.2
	errno@0.3.14
	exr@1.74.0
	fastrand@2.3.0
	fax@0.2.6
	fax_derive@0.2.0
	fdeflate@0.3.7
	find-msvc-tools@0.1.5
	flate2@1.1.5
	getrandom@0.3.4
	gif@0.14.1
	half@2.7.1
	icy_sixel@0.1.3
	image-webp@0.2.4
	image@0.25.9
	imgref@1.12.0
	interpolate_name@0.2.4
	is_terminal_polyfill@1.70.2
	itertools@0.14.0
	jobserver@0.1.34
	lebe@0.5.3
	libc@0.2.178
	libfuzzer-sys@0.4.10
	linux-raw-sys@0.11.0
	litrs@1.0.0
	lock_api@0.4.14
	log@0.4.29
	loop9@0.1.5
	make-cmd@0.1.0
	maybe-rayon@0.1.1
	memchr@2.7.6
	miniz_oxide@0.8.9
	moxcms@0.7.11
	new_debug_unreachable@1.0.6
	nix@0.30.1
	nom@8.0.0
	noop_proc_macro@0.3.0
	num-bigint@0.4.6
	num-derive@0.4.2
	num-integer@0.1.46
	num-rational@0.4.2
	num-traits@0.2.19
	objc2-encode@4.1.0
	objc2@0.6.3
	once_cell@1.21.3
	once_cell_polyfill@1.70.2
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	paste@1.0.15
	pastey@0.1.1
	png@0.18.0
	ppv-lite86@0.2.21
	proc-macro2@1.0.103
	profiling-procmacros@1.0.17
	profiling@1.0.17
	pxfm@0.1.27
	qoi@0.4.1
	quick-error@2.0.1
	quote@1.0.42
	r-efi@5.3.0
	rand@0.9.2
	rand_chacha@0.9.0
	rand_core@0.9.3
	rav1e@0.8.1
	ravif@0.12.0
	rayon-core@1.13.0
	rayon@1.11.0
	redox_syscall@0.5.18
	rgb@0.8.52
	rustix@1.1.2
	rustversion@1.0.22
	scopeguard@1.2.0
	shlex@1.3.0
	simd-adler32@0.3.8
	simd_helpers@0.1.0
	sixel-rs@0.5.0
	sixel-sys@0.5.0
	smallvec@1.15.1
	stable_deref_trait@1.2.1
	strsim@0.11.1
	syn@2.0.111
	tempfile@3.23.0
	termcolor@1.4.1
	thiserror-impl@2.0.17
	thiserror@2.0.17
	tiff@0.10.3
	unicode-ident@1.0.22
	utf8parse@0.2.2
	v_frame@0.3.9
	viuer@0.11.0
	wasip2@1.0.1+wasi-0.2.4
	wasm-bindgen-macro-support@0.2.106
	wasm-bindgen-macro@0.2.106
	wasm-bindgen-shared@0.2.106
	wasm-bindgen@0.2.106
	weezl@0.1.12
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-link@0.2.1
	windows-sys@0.61.2
	wit-bindgen@0.46.0
	y4m@0.8.0
	zerocopy-derive@0.8.31
	zerocopy@0.8.31
	zune-core@0.4.12
	zune-core@0.5.0
	zune-inflate@0.2.54
	zune-jpeg@0.4.21
	zune-jpeg@0.5.7
"

RUST_MIN_VER="1.88.0"
inherit cargo

DESCRIPTION="Terminal image viewer with native support for iTerm and Kitty"
HOMEPAGE="https://github.com/atanunq/viu"
SRC_URI="
	https://github.com/atanunq/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	BSD-2 BSD LGPL-3+ MIT UoI-NCSA Unicode-3.0
	|| ( Apache-2.0 CC0-1.0 )
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="icy-sixel sixel"
REQUIRED_USE="?? ( sixel icy-sixel )"

src_configure() {
	local myfeatures=(
		$(usex icy-sixel icy_sixel '')
		$(usev sixel)
	)
	cargo_src_configure
}
