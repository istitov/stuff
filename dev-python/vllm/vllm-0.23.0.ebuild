# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1
ROCM_VERSION=7.2

RUST_MIN_VER="1.89.0"

# vllm 0.22.0 ships a Rust frontend binary (vllm-rs) built via
# setuptools-rust from the bundled rust/ workspace.  Vendor its crate
# dependencies (generated from rust/Cargo.lock) rather than relying on a
# network-sandbox bypass, per the overlay's Rust+Python convention.  The
# frontend is opt-in at runtime (VLLM_USE_RUST_FRONTEND=1, default off);
# vllm's Python API server stays the default, so the binary is a
# performance option, not load-bearing.
CRATES="
	adler2@2.0.1
	ahash@0.8.12
	aho-corasick@1.1.4
	aligned-vec@0.6.4
	aligned@0.4.3
	android_system_properties@0.1.5
	anes@0.1.6
	anstream@0.6.21
	anstream@1.0.0
	anstyle-parse@0.2.7
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.13
	anyhow@1.0.102
	arbitrary@1.4.2
	arc-swap@1.9.0
	arg_enum_proc_macro@0.3.4
	arrayref@0.3.9
	arrayvec@0.7.6
	as-slice@0.2.1
	async-io@2.6.0
	async-openai-macros@0.1.1
	async-openai@0.33.1
	async-trait@0.1.89
	asynchronous-codec@0.7.0
	asynk-strim-attr-macro@0.1.0
	asynk-strim-attr@0.1.0
	asynk-strim@0.1.5
	atomic-waker@1.1.2
	autocfg@1.5.0
	av-scenechange@0.14.1
	av1-grain@0.2.5
	avif-serialize@0.8.8
	axum-core@0.5.6
	axum@0.8.8
	backoff@0.4.0
	base64@0.13.1
	base64@0.22.1
	base64ct@1.8.3
	bit-set@0.5.3
	bit-set@0.8.0
	bit-vec@0.6.3
	bit-vec@0.8.0
	bit_field@0.10.3
	bitflags@2.11.0
	bitstream-io@4.10.0
	blake3@1.8.5
	block-buffer@0.10.4
	bstr@1.12.1
	built@0.8.0
	bumpalo@3.20.2
	bytemuck@1.25.0
	bytemuck_derive@1.10.2
	byteorder-lite@0.1.0
	byteorder@1.5.0
	bytes@1.11.1
	cast@0.3.0
	castaway@0.2.4
	cc@1.2.56
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	chrono@0.4.44
	ciborium-io@0.2.2
	ciborium-ll@0.2.2
	ciborium@0.2.2
	clap@4.5.60
	clap_builder@4.5.60
	clap_derive@4.5.55
	clap_lex@1.0.0
	color_quant@1.1.0
	colorchoice@1.0.4
	compact_str@0.9.0
	concurrent-queue@2.5.0
	console@0.15.11
	console@0.16.2
	constant_time_eq@0.4.2
	cookie@0.18.1
	cookie_store@0.22.1
	core-foundation-sys@0.8.7
	core-foundation@0.10.1
	core-foundation@0.9.4
	cpufeatures@0.2.17
	cpufeatures@0.3.0
	crc32fast@1.5.0
	criterion-plot@0.5.0
	criterion@0.5.1
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-queue@0.3.12
	crossbeam-utils@0.8.21
	crunchy@0.2.4
	crypto-common@0.1.7
	daachorse@1.0.0
	darling@0.20.11
	darling@0.23.0
	darling_core@0.20.11
	darling_core@0.23.0
	darling_macro@0.20.11
	darling_macro@0.23.0
	dary_heap@0.3.8
	der@0.8.0
	deranged@0.5.8
	derive_builder@0.20.2
	derive_builder_core@0.20.2
	derive_builder_macro@0.20.2
	derive_more-impl@1.0.0
	derive_more@1.0.0
	digest@0.10.7
	dirs-sys@0.5.0
	dirs@6.0.0
	displaydoc@0.2.5
	dissimilar@1.0.11
	document-features@0.2.12
	dtoa@1.0.11
	dyn-clone@1.0.20
	easy-ext@1.0.3
	educe@0.6.0
	either@1.15.0
	encode_unicode@1.0.0
	encoding_rs@0.8.35
	enum-as-inner@0.7.0
	enum-ordinalize-derive@4.3.2
	enum-ordinalize@4.3.2
	env_filter@1.0.1
	env_logger@0.11.10
	equator-macro@0.4.2
	equator@0.4.2
	equivalent@1.0.2
	errno@0.3.14
	esaxx-rs@0.1.10
	eventsource-stream@0.2.3
	expect-test@1.5.1
	exr@1.74.0
	fancy-regex@0.13.0
	fancy-regex@0.17.0
	fast_image_resize@6.0.0
	fastokens@0.2.0
	fastrand@2.3.0
	fax@0.2.6
	fax_derive@0.2.0
	fdeflate@0.3.7
	find-msvc-tools@0.1.9
	fixedbitset@0.5.7
	flate2@1.1.9
	fnv@1.0.7
	foldhash@0.1.5
	foreign-types-shared@0.1.1
	foreign-types@0.3.2
	form_urlencoded@1.2.2
	fslock@0.2.1
	futures-channel@0.3.32
	futures-core@0.3.32
	futures-executor@0.3.32
	futures-io@0.3.32
	futures-lite@2.6.1
	futures-macro@0.3.32
	futures-sink@0.3.32
	futures-task@0.3.32
	futures-timer@3.0.3
	futures-util@0.3.32
	futures@0.3.32
	generic-array@0.14.7
	getopts@0.2.24
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.2
	gif@0.14.2
	h2@0.4.13
	half@2.7.1
	hashbrown@0.12.3
	hashbrown@0.14.5
	hashbrown@0.15.5
	hashbrown@0.16.1
	heck@0.5.0
	hermit-abi@0.5.2
	hex@0.4.3
	hf-hub@0.4.3
	hf-hub@0.5.0
	hmac@0.12.1
	hound@3.5.1
	http-body-util@0.1.3
	http-body@1.0.1
	http@1.4.0
	httparse@1.10.1
	httpdate@1.0.3
	hyper-rustls@0.27.7
	hyper-timeout@0.5.2
	hyper-tls@0.6.0
	hyper-util@0.1.20
	hyper@1.8.1
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	icu_collections@2.1.1
	icu_locale_core@2.1.1
	icu_normalizer@2.1.1
	icu_normalizer_data@2.1.1
	icu_properties@2.1.2
	icu_properties_data@2.1.2
	icu_provider@2.1.1
	id-arena@2.3.0
	ident_case@1.0.1
	idna@1.1.0
	idna_adapter@1.2.1
	image-webp@0.2.4
	image@0.25.10
	imgref@1.12.0
	indexmap@1.9.3
	indexmap@2.13.0
	indicatif@0.17.11
	indicatif@0.18.4
	instant@0.1.13
	interpolate_name@0.2.4
	ipnet@2.12.0
	iri-string@0.7.10
	is-macro@0.3.7
	is-terminal@0.4.17
	is_terminal_polyfill@1.70.2
	itertools@0.10.5
	itertools@0.11.0
	itertools@0.14.0
	itoa@1.0.17
	jiff-static@0.2.23
	jiff@0.2.23
	jobserver@0.1.34
	js-sys@0.3.91
	lalrpop-util@0.20.2
	lazy_static@1.5.0
	leb128fmt@0.1.0
	lebe@0.5.3
	libc@0.2.183
	libfuzzer-sys@0.4.12
	libm@0.2.16
	libmimalloc-sys@0.1.49
	libredox@0.1.14
	linux-raw-sys@0.12.1
	litemap@0.8.1
	litrs@1.0.0
	lock_api@0.4.14
	log@0.4.29
	loop9@0.1.5
	lru-slab@0.1.2
	macro_rules_attribute-proc_macro@0.2.2
	macro_rules_attribute@0.2.2
	malachite-base@0.4.22
	malachite-bigint@0.2.3
	malachite-nz@0.4.22
	malachite-q@0.4.22
	malachite@0.4.22
	matchers@0.2.0
	matchit@0.8.4
	matrixmultiply@0.3.10
	maybe-rayon@0.1.1
	memchr@2.8.0
	memo-map@0.3.3
	mimalloc@0.1.52
	mime@0.3.17
	mime_guess@2.0.5
	minijinja-contrib@2.18.0
	minijinja@2.18.0
	minimal-lexical@0.2.1
	miniz_oxide@0.8.9
	mio@1.1.1
	monostate-impl@0.1.18
	monostate@0.1.18
	moxcms@0.8.1
	multimap@0.10.1
	native-tls@0.2.18
	ndarray@0.16.1
	ndarray@0.17.2
	new_debug_unreachable@1.0.6
	no_std_io2@0.9.3
	nom@7.1.3
	nom@8.0.0
	noop_proc_macro@0.3.0
	nu-ansi-term@0.50.3
	num-bigint@0.4.6
	num-complex@0.4.6
	num-conv@0.2.0
	num-derive@0.4.2
	num-integer@0.1.46
	num-rational@0.4.2
	num-traits@0.2.19
	num_cpus@1.17.0
	num_threads@0.1.7
	number_prefix@0.4.0
	once_cell@1.21.3
	once_cell_polyfill@1.70.2
	onig@6.5.1
	onig_sys@69.9.1
	oorandom@11.1.5
	openai-harmony@0.0.8
	openai-protocol@1.6.0
	openssl-macros@0.1.1
	openssl-probe@0.2.1
	openssl-src@300.5.5+3.5.5
	openssl-sys@0.9.112
	openssl@0.10.76
	option-ext@0.2.0
	parking@2.2.1
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	paste@1.0.15
	pastey@0.1.1
	pcre2-sys@0.2.10
	pcre2@0.2.11
	pem-rfc7468@1.0.0
	percent-encoding@2.3.2
	petgraph@0.8.3
	phf@0.11.3
	phf_codegen@0.11.3
	phf_generator@0.11.3
	phf_shared@0.11.3
	pin-project-internal@1.1.11
	pin-project-lite@0.2.17
	pin-project@1.1.11
	pin-utils@0.1.0
	pkg-config@0.3.32
	plotters-backend@0.3.7
	plotters-svg@0.3.7
	plotters@0.3.7
	png@0.18.1
	polling@3.11.0
	portable-atomic-util@0.2.6
	portable-atomic@1.13.1
	potential_utf@0.1.4
	powerfmt@0.2.0
	ppv-lite86@0.2.21
	prettyplease@0.2.37
	primal-check@0.3.4
	proc-macro-crate@3.5.0
	proc-macro-error-attr2@2.0.0
	proc-macro-error2@2.0.1
	proc-macro2@1.0.106
	profiling-procmacros@1.0.17
	profiling@1.0.17
	prometheus-client-derive-encode@0.5.0
	prometheus-client@0.24.0
	prost-build@0.14.3
	prost-derive@0.14.3
	prost-types@0.14.3
	prost@0.14.3
	pulldown-cmark-to-cmark@22.0.0
	pulldown-cmark@0.13.3
	pxfm@0.1.29
	qoi@0.4.1
	quick-error@2.0.1
	quinn-proto@0.11.14
	quinn-udp@0.5.14
	quinn@0.11.9
	quote@1.0.45
	r-efi@5.3.0
	r-efi@6.0.0
	rand@0.8.5
	rand@0.9.2
	rand_chacha@0.3.1
	rand_chacha@0.9.0
	rand_core@0.6.4
	rand_core@0.9.5
	rav1e@0.8.1
	ravif@0.13.0
	rawpointer@0.2.1
	rayon-cond@0.4.0
	rayon-core@1.13.0
	rayon@1.11.0
	realfft@3.5.0
	redox_syscall@0.5.18
	redox_users@0.5.2
	ref-cast-impl@1.0.25
	ref-cast@1.0.25
	regex-automata@0.4.14
	regex-syntax@0.8.10
	regex@1.12.3
	reqwest-eventsource@0.6.0
	reqwest@0.12.28
	rgb@0.8.53
	ring@0.17.14
	riptoken@0.3.0
	rmp-serde@1.3.1
	rmp@0.8.15
	rmpv@1.3.1
	rubato@0.16.2
	rustc-hash@1.1.0
	rustc-hash@2.1.1
	rustfft@6.4.1
	rustix@1.1.4
	rustls-native-certs@0.8.3
	rustls-pki-types@1.14.0
	rustls-webpki@0.103.9
	rustls@0.23.37
	rustpython-ast@0.4.0
	rustpython-parser-core@0.4.0
	rustpython-parser-vendored@0.4.0
	rustpython-parser@0.4.0
	rustversion@1.0.22
	ryu@1.0.23
	saa@5.5.0
	same-file@1.0.6
	scc@2.4.0
	scc@3.6.9
	schannel@0.1.29
	schemars@0.8.22
	schemars@0.9.0
	schemars@1.2.1
	schemars_derive@0.8.22
	scopeguard@1.2.0
	sdd@3.0.10
	sdd@4.7.3
	secrecy@0.10.3
	security-framework-sys@2.17.0
	security-framework@3.7.0
	semver@1.0.27
	serde-json-fmt@0.1.0
	serde@1.0.228
	serde_bytes@0.11.19
	serde_core@1.0.228
	serde_default@0.2.0
	serde_derive@1.0.228
	serde_derive_internals@0.29.1
	serde_json@1.0.149
	serde_path_to_error@0.1.20
	serde_repr@0.1.20
	serde_tuple@1.1.3
	serde_tuple_macros@1.1.3
	serde_urlencoded@0.7.1
	serde_with@3.18.0
	serde_with_macros@3.18.0
	serial_test@3.4.0
	serial_test_derive@3.4.0
	sha1@0.10.6
	sha2@0.10.9
	sharded-slab@0.1.7
	shlex@1.3.0
	signal-hook-registry@1.4.8
	simd-adler32@0.3.8
	simd_helpers@0.1.0
	siphasher@1.0.2
	slab@0.4.12
	smallvec@1.15.1
	smartstring@1.0.1
	socket2@0.6.3
	socks@0.3.4
	spm_precompiled@0.1.4
	stable_deref_trait@1.2.1
	static_assertions@1.1.0
	strength_reduce@0.2.4
	strsim@0.11.1
	strum@0.27.2
	strum_macros@0.27.2
	subenum@1.1.3
	subtle@2.6.1
	syn@1.0.109
	syn@2.0.117
	sync_wrapper@1.0.2
	synstructure@0.13.2
	system-configuration-sys@0.6.0
	system-configuration@0.7.0
	task-local@0.1.1
	tekken-rs@0.1.1
	tempfile@3.27.0
	thiserror-ext-derive@0.3.0
	thiserror-ext@0.3.0
	thiserror-impl@1.0.69
	thiserror-impl@2.0.18
	thiserror@1.0.69
	thiserror@2.0.18
	thread_local@1.1.9
	tiff@0.11.3
	tiktoken-rs@0.7.0
	tiktoken-rs@0.9.1
	time-core@0.1.8
	time-macros@0.2.27
	time@0.3.47
	tiny-keccak@2.0.2
	tinystr@0.8.2
	tinytemplate@1.2.1
	tinyvec@1.11.0
	tinyvec_macros@0.1.1
	tokenizers@0.22.2
	tokio-macros@2.6.1
	tokio-native-tls@0.3.1
	tokio-rustls@0.26.4
	tokio-stream@0.1.18
	tokio-tungstenite@0.28.0
	tokio-util@0.7.18
	tokio@1.50.0
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.25.11+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	tonic-build@0.14.5
	tonic-prost-build@0.14.5
	tonic-prost@0.14.5
	tonic@0.14.5
	tool-parser@1.2.0
	tower-http@0.6.8
	tower-layer@0.3.3
	tower-service@0.3.3
	tower@0.5.3
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing-futures@0.2.5
	tracing-log@0.2.0
	tracing-subscriber@0.3.22
	tracing@0.1.44
	trait-set@0.3.0
	transpose@0.2.3
	try-lock@0.2.5
	tungstenite@0.28.0
	typenum@1.19.0
	unic-char-property@0.9.0
	unic-char-range@0.9.0
	unic-common@0.9.0
	unic-emoji-char@0.9.0
	unic-ucd-ident@0.9.0
	unic-ucd-version@0.9.0
	unicase@2.9.0
	unicode-ident@1.0.24
	unicode-normalization-alignments@0.1.12
	unicode-segmentation@1.13.1
	unicode-width@0.2.2
	unicode-xid@0.2.6
	unicode_categories@0.1.1
	unicode_names2@1.3.0
	unicode_names2_generator@1.3.0
	unit-prefix@0.5.2
	untrusted@0.9.0
	ureq-proto@0.6.0
	ureq@2.12.1
	ureq@3.3.0
	url@2.5.8
	utf-8@0.7.6
	utf16_iter@1.0.5
	utf8-zero@0.8.1
	utf8_iter@1.0.4
	utf8parse@0.2.2
	uuid@1.22.0
	v_frame@0.3.9
	validator@0.20.0
	validator_derive@0.20.0
	valuable@0.1.1
	vcpkg@0.2.15
	version_check@0.9.5
	walkdir@2.5.0
	want@0.3.1
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.2+wasi-0.2.9
	wasip3@0.4.0+wasi-0.3.0-rc-2026-01-06
	wasm-bindgen-futures@0.4.64
	wasm-bindgen-macro-support@0.2.114
	wasm-bindgen-macro@0.2.114
	wasm-bindgen-shared@0.2.114
	wasm-bindgen@0.2.114
	wasm-encoder@0.244.0
	wasm-metadata@0.244.0
	wasm-streams@0.4.2
	wasmparser@0.244.0
	web-sys@0.3.91
	web-time@1.1.0
	webpki-root-certs@1.0.6
	webpki-roots@0.26.11
	webpki-roots@1.0.6
	weezl@0.1.12
	win_uds@0.2.2
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-core@0.62.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-registry@0.6.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-sys@0.60.2
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows-targets@0.53.5
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_gnullvm@0.53.1
	windows_aarch64_msvc@0.52.6
	windows_aarch64_msvc@0.53.1
	windows_i686_gnu@0.52.6
	windows_i686_gnu@0.53.1
	windows_i686_gnullvm@0.52.6
	windows_i686_gnullvm@0.53.1
	windows_i686_msvc@0.52.6
	windows_i686_msvc@0.53.1
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnu@0.53.1
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_gnullvm@0.53.1
	windows_x86_64_msvc@0.52.6
	windows_x86_64_msvc@0.53.1
	winnow@1.0.2
	wit-bindgen-core@0.51.0
	wit-bindgen-rust-macro@0.51.0
	wit-bindgen-rust@0.51.0
	wit-bindgen@0.51.0
	wit-component@0.244.0
	wit-parser@0.244.0
	write16@1.0.0
	writeable@0.6.2
	y4m@0.8.0
	yoke-derive@0.8.1
	yoke@0.8.1
	zerocopy-derive@0.8.42
	zerocopy@0.8.42
	zerofrom-derive@0.1.6
	zerofrom@0.1.6
	zeroize@1.8.2
	zeromq@0.6.0
	zerotrie@0.2.3
	zerovec-derive@0.11.2
	zerovec@0.11.5
	zmij@1.0.21
	zune-core@0.5.1
	zune-inflate@0.2.54
	zune-jpeg@0.5.15
"
declare -A GIT_CRATES=(
	[llm-multimodal]='https://github.com/vllm-project/llm-multimodal;5b558989844d1c7af3e43d0f604069ffd9c06320;llm-multimodal-%commit%'
)

# The Rust frontend (vllm-rs) is opt-in at runtime (VLLM_USE_RUST_FRONTEND=1,
# default off) and a heavy 600+-crate build, so gate it behind USE=rust rather
# than building it for every install. CARGO_OPTIONAL stops the cargo eclass from
# auto-adding its BDEPEND/SRC_URI/phase functions; we wire those under rust?
# below and call cargo_src_unpack manually.
CARGO_OPTIONAL=1

inherit cargo distutils-r1 pypi rocm toolchain-funcs

# Commit pinned by cmake/external_projects/vllm_flash_attn.cmake (GIT_TAG).
# Pre-staged so we can patch out FA3's unconditional-build quirk before
# vllm's CMake FetchContent reaches it.  Bump in lockstep with vllm
# bumps that change the pin.
VLLM_FA_COMMIT="dd62dac706b1cf7895bd99b18c6cb7e7e117ee25"

DESCRIPTION="High-throughput, memory-efficient inference and serving engine for LLMs"
HOMEPAGE="
	https://github.com/vllm-project/vllm
	https://docs.vllm.ai/
	https://pypi.org/project/vllm/
"
SRC_URI+="
	rust? ( ${CARGO_CRATE_URIS} )
	cuda? (
		https://github.com/vllm-project/flash-attention/archive/${VLLM_FA_COMMIT}.tar.gz
			-> vllm-flash-attn-${VLLM_FA_COMMIT:0:7}.gh.tar.gz
	)
"

LICENSE="Apache-2.0"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD CC0-1.0 CDLA-Permissive-2.0 ISC LGPL-3 MIT
	MPL-2.0 MPL-2.0 UoI-NCSA Unicode-3.0 Unicode-DFS-2016 Unlicense ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cpu cuda humming rocm rust"
# VLLM_TARGET_DEVICE is single-valued; cpu, cuda, and rocm paths are
# mutually exclusive. Default (none) → empty target. USE=rust is
# orthogonal — it builds the optional vllm-rs Rust serving frontend
# (opt-in at runtime via VLLM_USE_RUST_FRONTEND=1) and combines with any
# target.
REQUIRED_USE="
	?? ( cpu cuda rocm )
	rocm? ( || ( ${ROCM_REQUIRED_USE} ) )
	humming? ( cuda )
"

# USE=cpu (default off): build with VLLM_TARGET_DEVICE=cpu so the
# Python entrypoints can actually drive inference on CPU hardware.
# Pulls torchaudio + numba (vllm's cpu.txt also lists intel-openmp on
# x86_64, but Intel ships it as a proprietary blob — we omit it; vllm
# falls back to the pthreads OpenMP shipped with sci-libs/openblas etc.)
#
# CAVEAT (historical): ::gentoo sci-ml/pytorch's caffe2::mkl public
# link interface used to drag MKL's MPI / cluster libs (scalapack,
# cdft, blacs_intelmpi) and Intel-OpenMP threading (intel_thread)
# into every consumer link, breaking the build on hosts without
# Intel Cluster Edition + Compiler. We pin >=sci-ml/caffe2-2.11.0-r90
# below — this overlay's r90 fork ships a scrub patch on
# cmake/public/mkl.cmake that filters those libs and forces
# gnu_thread. Drop the pin once an equivalent upstream fix lands.
#
# USE=cuda: build with VLLM_TARGET_DEVICE=cuda. Pulls torchaudio +
# torchvision + numba and the full Tier-0..5 CUDA stack (flashinfer
# + tilelang + nvidia-cutlass-dsl + cuda-bindings + nvidia-cudnn-
# frontend + ...). Compiles the _C / _moe_C / _vllm_fa* CUDA C++
# extensions in setup.py via nvcc and the system CUDA toolkit at
# /opt/cuda. CMAKE_CUDA_HOST_COMPILER is pinned to the gcc-15 slot
# below — CUDA 13.2's nvcc rejects __GNUC__>15 via host_config.h
# (see feedback_cuda_13_host_compiler_gcc_15.md). FetchContent of
# CUTLASS / spdlog / etc. happens during the vllm CMake build, so
# RESTRICT="cuda? ( network-sandbox )" mirrors the cpu? pattern.
#
# CAVEAT (historical): same MKL-MPI link pollution as USE=cpu —
# ::gentoo sci-ml/pytorch with USE=mkl exported MKL MPI / cluster
# libs in its public link interface, breaking the cumem_allocator
# extension's link step on partial-MKL hosts. Fixed by the
# >=sci-ml/caffe2-2.11.0-r90 pin below: this overlay's r90 fork
# scrubs those libs from caffe2::mkl. Without that pin, all 339
# CUDA-compiled objects (_C / _moe_C / _vllm_fa2/3 extensions)
# would still build cleanly but the final cumem_allocator link
# would fail with "cannot find -lmkl_scalapack_ilp64".
#
# USE=rocm: build with VLLM_TARGET_DEVICE=rocm. Pulls torchaudio +
# torchvision + numba + the runai-streamer/tensorizer/conch-triton
# trio from upstream's requirements/rocm.txt, plus the HIP libs that
# vllm's CMake `enable_language(HIP)` and the linked libtorch_hip
# resolve at link time (hipBLAS / hipBLASLt / hipFFT / hipRAND /
# hipSOLVER / hipSPARSE / hipCUB). Compiles the _C / _moe_C / _rocm_C
# extensions and csrc/rocm/*.cu via hipcc and the system ROCm
# toolchain at /opt/rocm. Inherits sci-ml/caffe2's MKL-MPI scrub
# (>=2.11.0-r90) — same link-pollution caveat as the cuda path.
# PYTORCH_ROCM_ARCH is derived from AMDGPU_TARGETS via rocm.eclass's
# get_amdgpu_flags. FetchContent of CK / spdlog / etc. happens during
# the vllm CMake build, hence RESTRICT="rocm? ( network-sandbox )".
#
# amd-quark (in requirements/rocm.txt as "for Quark quantization on
# ROCm") is deliberately omitted from RDEPEND: no direct `import` from
# vllm core code, only used by vllm.model_executor.layers.quantization.
# quark internals when Quark-quantized models are loaded.
# dev-python/amd-quark-bin in this overlay caps PYTHON_COMPAT at
# 3.{11,12}, which would block vllm on 3.13/3.14. Users wanting Quark
# quantization install amd-quark-bin separately.
#
# Upstream requirements/cuda.txt pins nvidia-cutlass-dsl[cu13]==4.5.2,
# tilelang==0.1.9 and flashinfer-python==0.6.12 exactly; we pin
# ~nvidia-cutlass-dsl-4.5.2 and ~flashinfer-python-0.6.12 to match.
# The cutlass-dsl metapackage pulls nvidia-cutlass-dsl-libs-cu13
# transitively, so it already covers the [cu13] extra. 0.23.0 raises the
# nvidia-cudnn-frontend floor to >=1.19.1 (0.22.x wanted <1.19.0); that
# dep lives on the flashinfer-python ebuild — vllm has zero direct
# cudnn_frontend imports; it is for flashinfer's internal use. fastsafetensors
# floor rose 0.2.2 -> 0.3.2.
# # static cuda.txt audit 2026-06-13 against vllm-0.23.0 (rocm gfx1150 +
# # cpu + empty + USE=rust build-verified 2026-06-13; cuda sm_86 GPU
# # build re-verification still pending).
#
# tokenspeed-mla (in requirements/cuda.txt at ==0.1.2 with the comment
# "for faster mla with spec decode") is deliberately omitted from
# cuda?'s RDEPEND for similar reasons: all imports in vllm core are
# lazy and gated by try/except with a clear pip-install hint, the
# kernels are Blackwell SM100/SM103-only (irrelevant on Ampere/Hopper
# hosts), and the package transitively pulls tokenspeed-triton — a
# Triton vendor-fork we'd otherwise have to package as a hard build
# dep for a backend most users never enable. Users on Blackwell with
# DeepSeek R1 + spec decode install tokenspeed-mla separately.
# # verified 2026-05-16: vllm imports clean without it.
#
# humming-kernels[cu13] (requirements/cuda.txt, ==0.1.4 "for quantization
# gemm") provides the optional `humming` quant backend -- pulled only
# under USE=humming. vllm's quant registry imports `.humming` for any
# quant method, and humming.py imports the external `humming` package
# under `if current_platform.is_cuda():` with no fallback, so a cuda
# build without it aborts on every quantized model load. The
# ${P}-humming-import-optional.patch guards that import so the other
# quant methods still work with USE=-humming; upstream makes it lazy in
# vllm > 0.23.0 (vllm-project/vllm#44921). # 2026-06-15
# gfx1150 (Strix Point iGPU) rocm build verified on
# caffe2[rocm,amdgpu_targets_gfx1150,-nccl,-cusparselt] with
# AMDGPU_TARGETS=gfx1150.  Produces the HIP extensions (_C,
# _C_stable_libtorch, _moe_C, _rocm_C, cumem_allocator, spinloop) and
# installs cleanly.
# # verified 2026-05-08 for 0.20.1, 2026-05-16 for 0.21.0, 2026-06-13 for
# # 0.23.0 (with pytorch/caffe2 2.11.0; cpu + empty + USE=rust also OK).
#
# RTX A4500 Laptop (sm_86 Ampere) cuda build verified on
# caffe2-2.11.0-r90 + CUDA-13.2 + CUDAHOSTCXX=g++-15 + MAX_JOBS=4.
# Pre-FA3-skip baseline: ~2h30m wallclock, 339 CUDA template files
# (FA3 .cu compiled at nvcc's default arch — wasted on Ampere).
# Post-FA3-skip (next commit, files/vllm-flash-attn-...-fa3-only-
# when-archs.patch): ~1h35m wallclock, 144 CUDA template files.
# Peak ~14 GiB RSS in either case (16 GiB free headroom on 31 GiB
# host).  Smoke test in both shapes: `from vllm import LLM`
# succeeds, torch.cuda.is_available() True, torch reports "NVIDIA
# RTX A4500 Laptop GPU"; FA2 kernels build for sm_80+PTX (forward-
# compat with sm_86); FA3 (Hopper) does NOT build on sm_86 in the
# post-patch shape (FA3_AVAILABLE=False at runtime, vllm picks FA2).
# # verified 2026-05-17 for 0.21.0 on sm_86 + CUDA 13.2 (both shapes).
#
# USE=-cpu -cuda -rocm (default): build with VLLM_TARGET_DEVICE=empty
# — Python entrypoints import cleanly, backend kernels fail at first
# model-load. Useful if you only want the API surface for development.
#
# media-libs/opencv lower bound: upstream requirements/common.txt says
# opencv-python-headless >=4.13.0, ::gentoo tops at 4.12.0.  The full
# cv2 surface vllm imports — resize, cvtColor, COLOR_BGR2RGB,
# CAP_PROP_FRAME_COUNT/FPS/FRAME_WIDTH/FRAME_HEIGHT, VideoCapture incl.
# the 3-arg bytes+backend form, VideoWriter, VideoWriter_fourcc,
# videoio_registry submodule — is present in 4.12.0; the 4.13 lower
# bound upstream is wheel-publication churn, not an API extension.
# # verified 2026-05-16 against media-libs/opencv-4.12.0-r1[python].
#
# vllm resolves its runtime platform from the host hardware (not the
# VLLM_TARGET_DEVICE built below). platforms/cuda.py / rocm.py import
# torch.distributed.PrefixStore + ProcessGroup unconditionally at module
# load (needs USE=distributed), and at engine init vllm builds a CPU
# coordination group on the gloo backend. Since our caffe2 builds CUDA
# with USE_NCCL=OFF, vllm's nccl device group also falls back to gloo, so
# USE=gloo is required too. Both flags are default-off: without
# caffe2[distributed,gloo] vllm ImportErrors at startup, or
# AssertionErrors ("Fallback Gloo backend is not available") at engine
# init. verified 2026-06-14, bug #274
#
# vllm's GPU kernels (slot mapping, attention, sampling, and the
# torch.compile/inductor path) are @triton.jit on both the cuda and
# rocm targets -- on ROCm, vllm's custom paged-attention also falls
# back to a Triton kernel on gfx targets without it (e.g. gfx1150).
# Gentoo's source-built torch does not pull Triton the way upstream's
# PyPI wheels do, so the cuda? and rocm? targets require
# dev-python/triton-bin or vllm dies at first GPU inference with
# "'function' object is not subscriptable". torch-2.11.0 pairs with
# triton 3.6.0; its AMD backend JITs gfx kernels via hipcc. cuda
# verified 2026-06-14 (bug #274); rocm gfx1150 verified 2026-06-14
# (opt-125m generated, inductor path + Triton _fwd_kernel).
RDEPEND="
	~sci-ml/pytorch-2.11.0[${PYTHON_SINGLE_USEDEP}]
	sci-ml/caffe2[distributed,gloo]
	>=sci-ml/transformers-4.56.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/tokenizers-0.21.1[${PYTHON_SINGLE_USEDEP}]
	>=dev-python/xgrammar-0.2.0[${PYTHON_SINGLE_USEDEP}]
	<dev-python/xgrammar-1.0.0[${PYTHON_SINGLE_USEDEP}]
	~dev-python/compressed-tensors-0.17.0[${PYTHON_SINGLE_USEDEP}]
	app-alternatives/ninja
	$(python_gen_cond_dep '
		dev-python/regex[${PYTHON_USEDEP}]
		dev-python/cachetools[${PYTHON_USEDEP}]
		dev-python/psutil[${PYTHON_USEDEP}]
		sci-ml/sentencepiece[${PYTHON_USEDEP}]
		>=sci-ml/safetensors-0.6.2[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		>=dev-python/requests-2.26.0[${PYTHON_USEDEP}]
		dev-python/tqdm[${PYTHON_USEDEP}]
		dev-python/blake3[${PYTHON_USEDEP}]
		dev-python/py-cpuinfo[${PYTHON_USEDEP}]
		>=dev-python/protobuf-5.29.6[${PYTHON_USEDEP}]
		>=dev-python/fastapi-0.115.0[${PYTHON_USEDEP}]
		>=dev-python/aiohttp-3.13.3[${PYTHON_USEDEP}]
		>=dev-python/openai-2.0.0[${PYTHON_USEDEP}]
		>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
		>=dev-python/prometheus-client-0.18.0[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		>=dev-python/prometheus-fastapi-instrumentator-7.0.0[${PYTHON_USEDEP}]
		>=dev-python/tiktoken-0.6.0[${PYTHON_USEDEP}]
		~dev-python/lm-format-enforcer-0.11.3[${PYTHON_USEDEP}]
		>=dev-python/llguidance-1.7.0[${PYTHON_USEDEP}]
		<dev-python/llguidance-1.8.0[${PYTHON_USEDEP}]
		~dev-python/outlines-core-0.2.14[${PYTHON_USEDEP}]
		>=dev-python/diskcache-5.6.3[${PYTHON_USEDEP}]
		>=dev-python/lark-1.2.2[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.10[${PYTHON_USEDEP}]
		>=dev-python/filelock-3.16.1[${PYTHON_USEDEP}]
		dev-python/partial-json-parser[${PYTHON_USEDEP}]
		>=dev-python/pyzmq-25.0.0[${PYTHON_USEDEP}]
		dev-python/msgspec[${PYTHON_USEDEP}]
		>=dev-python/gguf-0.17.0[${PYTHON_USEDEP}]
		>=dev-python/mistral-common-1.11.3[${PYTHON_USEDEP},image]
		>=media-libs/opencv-4.12.0[python,${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
		dev-python/einops[${PYTHON_USEDEP}]
		~dev-python/depyf-0.20.0[${PYTHON_USEDEP}]
		dev-python/cloudpickle[${PYTHON_USEDEP}]
		dev-python/uvloop[${PYTHON_USEDEP}]
		dev-python/watchfiles[${PYTHON_USEDEP}]
		dev-python/python-json-logger[${PYTHON_USEDEP}]
		dev-python/pybase64[${PYTHON_USEDEP}]
		dev-python/cbor2[${PYTHON_USEDEP}]
		dev-python/ijson[${PYTHON_USEDEP}]
		dev-python/setproctitle[${PYTHON_USEDEP}]
		>=dev-python/openai-harmony-0.0.3[${PYTHON_USEDEP}]
		>=dev-python/anthropic-0.71.0[${PYTHON_USEDEP}]
		>=dev-python/model-hosting-container-standards-0.1.14[${PYTHON_USEDEP}]
		<dev-python/model-hosting-container-standards-1.0.0[${PYTHON_USEDEP}]
		dev-python/mcp[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-sdk-1.27.0[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-api-1.27.0[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-exporter-otlp-1.27.0[${PYTHON_USEDEP}]
		>=dev-python/opentelemetry-semantic-conventions-ai-0.4.1[${PYTHON_USEDEP}]
	')
	cpu? (
		>=sci-ml/caffe2-2.11.0-r90
		~sci-ml/torchaudio-2.11.0
		$(python_gen_cond_dep '
			>=dev-python/numba-0.65.0[${PYTHON_USEDEP}]
		')
	)
	cuda? (
		>=sci-ml/caffe2-2.11.0-r90
		~sci-ml/torchaudio-2.11.0
		~sci-ml/torchvision-0.26.0[${PYTHON_SINGLE_USEDEP}]
		~dev-python/flashinfer-python-0.6.12[${PYTHON_SINGLE_USEDEP}]
		~dev-python/tilelang-0.1.9[${PYTHON_SINGLE_USEDEP}]
		>=dev-python/quack-kernels-0.3.3[${PYTHON_SINGLE_USEDEP}]
		humming? ( ~dev-python/humming-kernels-0.1.4[${PYTHON_SINGLE_USEDEP}] )
		$(python_gen_cond_dep '
			>=dev-python/numba-0.65.0[${PYTHON_USEDEP}]
			>=dev-python/fastsafetensors-0.3.2[${PYTHON_USEDEP}]
			~dev-python/nvidia-cutlass-dsl-4.5.2[${PYTHON_USEDEP}]
			~dev-python/triton-bin-3.6.0[${PYTHON_USEDEP}]
		')
		dev-util/nvidia-cuda-toolkit:=
	)
	rocm? (
		>=sci-ml/caffe2-2.11.0-r90
		~sci-ml/torchaudio-2.11.0
		~sci-ml/torchvision-0.26.0[${PYTHON_SINGLE_USEDEP}]
		>=dev-python/runai-model-streamer-bin-0.15.7[${PYTHON_SINGLE_USEDEP}]
		~dev-python/tensorizer-2.10.1[${PYTHON_SINGLE_USEDEP}]
		~dev-python/tilelang-0.1.10[${PYTHON_SINGLE_USEDEP}]
		$(python_gen_cond_dep '
			>=dev-python/numba-0.65.0[${PYTHON_USEDEP}]
			~dev-python/conch-triton-kernels-1.2.1[${PYTHON_USEDEP}]
			~dev-python/triton-bin-3.6.0[${PYTHON_USEDEP}]
			>=dev-util/amdsmi-7.0.2[${PYTHON_USEDEP}]
		')
		>=dev-util/hip-7.2:=
		>=sci-libs/hipBLAS-7.2:=
		>=sci-libs/hipBLASLt-7.2:=
		>=sci-libs/hipFFT-7.2:=
		>=sci-libs/hipRAND-7.2:=
		>=sci-libs/hipSOLVER-7.2:=
		>=sci-libs/hipSPARSE-7.2:=
		>=sci-libs/hipCUB-7.2:=
	)
"
# Upstream pyproject.toml caps setuptools at <81.0.0; dropped from
# BDEPEND because (a) gentoo only ships 79.0.1 + 82.0.1 (nothing in
# the 80.x/81.x line), and downgrading to 79.0.1 fights pkg-resources-
# 81.0.0 (which has !<setuptools-82 and is pulled in by html5lib /
# opcodes / python-xlib among others); and (b) vllm's setup.py uses
# only the standard setuptools surface (Extension, setup, build_ext)
# — no pkg_resources imports, no setuptools.command.* removed in 81+.
# Cap re-evaluate on bump. # verified 2026-05-16 against setup.py.
BDEPEND="
	>=dev-build/cmake-3.26.1
	app-alternatives/ninja
	~sci-ml/pytorch-2.11.0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		>=dev-python/setuptools-77.0.3[${PYTHON_USEDEP}]
		>=dev-python/setuptools-scm-8.0[${PYTHON_USEDEP}]
		>=dev-python/setuptools-rust-1.9.0[${PYTHON_USEDEP}]
		>=dev-python/packaging-24.2[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
	')
	rust? (
		${RUST_DEPEND}
		dev-lang/perl
	)
	cuda? (
		dev-util/nvidia-cuda-toolkit:=
	)
	rocm? (
		>=dev-util/hip-7.2:=
		>=dev-util/hipcc-7.2:=
	)
"

# Tests need a model+inference setup; not wired up here.
# CPU build fetches oneDNN v3.10 from GitHub via CMake FetchContent.
# CUDA build similarly uses FetchContent for CUTLASS / spdlog / etc.
# during the _C / _moe_C / _vllm_fa* extension compile. Both paths
# need the network-sandbox bypass. # verified 2026-05-07 against
# 0.20.1; 0.21.0's FetchContent set wasn't re-audited at bump time.
RESTRICT="
	test
	cpu? ( network-sandbox )
	cuda? ( network-sandbox )
	rocm? ( network-sandbox )
"

# 0.20.x carried a patch to relax cmake/cpu_extension.cmake's libgomp
# probe so it would fall back to the system gcc-runtime libgomp when
# torch.libs/ contains no vendored copy.  Upstream 0.21.0's cmake now
# has an equivalent fallback (find_library(OPEN_MP NAMES gomp REQUIRED)
# without NO_DEFAULT_PATH) when VLLM_TORCH_GOMP_SHIM_DIR is empty, so
# the local patch is no longer needed.

# Pretend the version so setuptools-scm doesn't probe git.
export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

src_unpack() {
	if use rust; then
		# Vendor the vllm-rs crate deps and set up CARGO_HOME for the
		# offline build (cargo_src_unpack also unpacks the sdist + any
		# cuda? flash-attn tarball normally).
		cargo_src_unpack
	else
		default
	fi
}

PATCHES=( "${FILESDIR}/${P}-humming-import-optional.patch" )

src_prepare() {
	distutils-r1_src_prepare

	if ! use rust; then
		# vllm's setup.py unconditionally wires the vllm-rs RustExtension.
		# With USE=-rust we ship no crates and set up no cargo, so drop the
		# extension list to keep setup.py from attempting a cargo build.
		# Guard the sed: it exits 0 on a no-match, so a future upstream
		# rename of this kwarg would silently leave the rust build active
		# and break the -rust build. Fail loudly instead.
		grep -q 'rust_extensions=rust_extensions,' setup.py ||
			die "vllm-rs RustExtension wiring changed; revisit the USE=rust gate"
		sed -i 's/rust_extensions=rust_extensions,/rust_extensions=[],/' \
			setup.py || die
	fi

	if use cuda; then
		# Pre-stage vllm-flash-attn and apply our local patches before
		# vllm's CMake FetchContent reaches it.  vllm honours
		# VLLM_FLASH_ATTN_SRC_DIR (set in src_configure) and skips the
		# git fetch when the dir already exists.
		local fa_dir="${WORKDIR}/flash-attention-${VLLM_FA_COMMIT}"
		[[ -d ${fa_dir} ]] || die "expected ${fa_dir} from SRC_URI unpack"
		pushd "${fa_dir}" >/dev/null || die
		# Skip the FA3 (Hopper) target body when no Hopper arch is in
		# CUDA_ARCHS so Ampere/Ada builds don't compile unrunnable kernels.
		eapply -p0 \
			"${FILESDIR}/vllm-flash-attn-${VLLM_FA_COMMIT:0:7}-fa3-only-when-archs.patch"
		# vllm's PYTHON_COMPAT allows python3_14, but flash-attn's
		# CMakeLists hard-codes a supported-Python whitelist and
		# FATAL_ERRORs on 3.14 at configure.  The extension is abi3
		# (USE_SABI 3), so widening that whitelist is safe.  bug #274
		eapply -p0 \
			"${FILESDIR}/vllm-flash-attn-${VLLM_FA_COMMIT:0:7}-py314.patch"
		popd >/dev/null || die
	fi
}

src_configure() {
	# When the Rust frontend is requested, make its build mandatory so a
	# failure errors out instead of setuptools-rust silently skipping the
	# optional extension.
	use rust && export VLLM_REQUIRE_RUST_FRONTEND=1

	if use cuda; then
		export VLLM_TARGET_DEVICE=cuda
		# Point vllm's cmake FetchContent at our pre-staged + patched
		# flash-attention source instead of re-fetching from github.
		export VLLM_FLASH_ATTN_SRC_DIR="${WORKDIR}/flash-attention-${VLLM_FA_COMMIT}"
		# CUDA 13.2's nvcc rejects gcc>15 via crt/host_config.h; this
		# host's active gcc is 16. Pin nvcc's host compiler to the
		# gcc-15 slot. See feedback_cuda_13_host_compiler_gcc_15.md
		# for the rationale and broader applicability.
		export CUDAHOSTCXX=/usr/bin/x86_64-pc-linux-gnu-g++-15
		export CMAKE_ARGS+=" -DCMAKE_CUDA_HOST_COMPILER=${CUDAHOSTCXX}"

		# vllm's heavy CUDA template instantiations
		# (paged_attention_v*, layernorm_quant_kernels, w8a8/fp8/...)
		# can each peak at 3-4 GiB during cudafe++. With ninja's
		# default 24-way parallelism this OOM-kills on a 31 GiB host
		# (cudafe++ dies with SIGKILL, "[code=9]"). MAX_JOBS is the
		# env var vllm's setup.py reads to throttle the CMake build;
		# CMAKE_BUILD_PARALLEL_LEVEL backs it up for direct cmake
		# --build invocations. Tune this per-host: 31 GiB → 4-6,
		# 54 GiB → 8-10, 128 GiB → ~16. The OOM threshold was measured
		# against 0.20.1; 0.21.0's CUDA template set wasn't re-profiled
		# at bump time but the heavy instantiations (paged_attention,
		# layernorm_quant, w8a8/fp8) are unchanged, so MAX_JOBS=4 stays
		# a conservative default. # verified 2026-05-07 against 0.20.1.
		#
		# Caller-overridable so users on smaller/larger hosts can adjust
		# without ebuild-edit (e.g. MAX_JOBS=2 emerge … on a 16 GiB
		# host).
		export MAX_JOBS="${MAX_JOBS:-4}"
		export CMAKE_BUILD_PARALLEL_LEVEL="${CMAKE_BUILD_PARALLEL_LEVEL:-${MAX_JOBS}}"
	elif use cpu; then
		export VLLM_TARGET_DEVICE=cpu
		# vllm 0.22.x cpu_extension.cmake locates OpenMP via
		# vllm_prepare_torch_gomp_shim(), which expects a libgomp vendored
		# inside PyTorch (torch.libs/libgomp-*.so — a PyPI-wheel artifact).
		# Our source-built sci-ml/caffe2 ships none, so cmake falls back to
		# find_library(NAMES gomp), which misses Gentoo's libgomp under the
		# gcc-internal dir. Point CMAKE_LIBRARY_PATH at the toolchain's
		# libgomp so the fallback resolves. # verified 2026-06-05 (0.22.1)
		local gomp_dir
		gomp_dir=$(dirname "$($(tc-getCC) -print-file-name=libgomp.so)")
		export CMAKE_ARGS+=" -DCMAKE_LIBRARY_PATH=${gomp_dir}"
	elif use rocm; then
		export VLLM_TARGET_DEVICE=rocm
		# rocm.eclass turns AMDGPU_TARGETS into a semicolon-joined
		# list. vllm's CMakeLists reads PYTORCH_ROCM_ARCH and feeds
		# it to enable_language(HIP). Same MAX_JOBS throttle as the
		# cuda branch — HIP template instantiation in csrc/rocm/
		# (skinny_gemms, attention) hits comparable peak RSS.
		export PYTORCH_ROCM_ARCH=$(get_amdgpu_flags)
		export MAX_JOBS="${MAX_JOBS:-4}"
		export CMAKE_BUILD_PARALLEL_LEVEL="${CMAKE_BUILD_PARALLEL_LEVEL:-${MAX_JOBS}}"
	else
		export VLLM_TARGET_DEVICE=empty
	fi
	distutils-r1_src_configure
}

pkg_postinst() {
	if use cuda; then
		elog "vllm's CUDA path pulls dev-python/flashinfer-python, which"
		elog "JIT-compiles GPU kernels with nvcc on first inference. CUDA"
		elog "13.x nvcc rejects host compilers newer than gcc 15, so if the"
		elog "active gcc is newer, vllm aborts at first run with a"
		elog "'Ninja build failed ... unsupported GNU version' error."
		elog ""
		elog "Pin nvcc's host compiler to a gcc <= 15 when launching vllm:"
		elog ""
		elog "  NVCC_PREPEND_FLAGS=\"-ccbin /usr/bin/${CHOST}-g++-15\" vllm serve ..."
		elog ""
		elog "or switch the system compiler via 'eselect gcc'."
	fi

	if use cuda && ! use humming; then
		elog ""
		elog "The optional 'humming' MXFP4 quantization backend is off by"
		elog "default. Enable USE=humming to pull dev-python/humming-kernels"
		elog "if you serve humming-quantized models."
	fi

	if use rocm; then
		elog "vllm initializes a torch.distributed process group at engine"
		elog "start (a TCPStore rendezvous) even for single-GPU inference."
		elog "Since torch 2.4 the TCPStore defaults to the libuv backend,"
		elog "but sci-ml/pytorch's ROCm build ships no libuv -- it rides in"
		elog "via tensorpipe, which is disabled for ROCm. Without it vllm"
		elog "aborts at engine init with:"
		elog ""
		elog "  DistStoreError: use_libuv was requested but PyTorch was"
		elog "  built without libuv support"
		elog ""
		elog "Launch vllm with USE_LIBUV=0 to use the legacy socket store:"
		elog ""
		elog "  USE_LIBUV=0 vllm serve ..."
	fi
}
