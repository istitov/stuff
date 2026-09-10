# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Generated with pycargoebuild 0.15.0 from both crate graphs. The core graph
# needs a generated lockfile; union both CRATES sets when bumping. ::gentoo's
# prebundled archives are unavailable for 0.23.2. verified 2026-09-09

EAPI=8

DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_EXT=1
DISTUTILS_SINGLE_IMPL=1
RUST_MIN_VER="1.87.0"

CRATES="
	adler2@2.0.1
	ahash@0.8.12
	aho-corasick@1.1.5
	anes@0.1.6
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	assert_approx_eq@1.1.0
	atomic-waker@1.1.2
	autocfg@1.5.1
	base64@0.13.1
	base64@0.22.1
	bit-set@0.8.0
	bit-vec@0.8.0
	bitflags@1.3.2
	bitflags@2.13.1
	bumpalo@3.20.3
	byteorder@1.5.0
	bytes@1.12.1
	cast@0.3.0
	castaway@0.2.4
	cc@1.4.4
	cc@1.4.5
	cfg-if@1.0.4
	cfg_aliases@0.2.2
	chacha20@0.10.2
	ciborium-io@0.2.2
	ciborium-ll@0.2.2
	ciborium@0.2.2
	clap@4.6.6
	clap_builder@4.6.6
	clap_lex@1.1.0
	colorchoice@1.0.5
	compact_str@0.9.1
	console@0.15.11
	console@0.16.4
	cpufeatures@0.3.1
	crc32fast@1.5.1
	criterion-plot@0.5.0
	criterion@0.6.0
	crossbeam-deque@0.8.7
	crossbeam-deque@0.8.8
	crossbeam-epoch@0.9.20
	crossbeam-epoch@0.9.21
	crossbeam-utils@0.8.22
	crossbeam-utils@0.8.23
	crunchy@0.2.4
	daachorse@3.0.3
	darling@0.20.11
	darling_core@0.20.11
	darling_macro@0.20.11
	dary_heap@0.3.9
	defmt-macros@1.1.1
	defmt-parser@1.0.0
	defmt@1.1.1
	derive_builder@0.20.2
	derive_builder_core@0.20.2
	derive_builder_macro@0.20.2
	dirs-sys@0.5.0
	dirs@6.0.0
	displaydoc@0.2.7
	either@1.18.0
	encode_unicode@1.0.0
	env_filter@2.0.0
	env_logger@0.11.11
	errno@0.3.14
	esaxx-rs@0.1.10
	fancy-regex@0.17.0
	fastrand@2.5.0
	find-msvc-tools@0.1.11
	find-msvc-tools@0.1.12
	flate2@1.1.10
	fnv@1.0.7
	form_urlencoded@1.2.2
	futures-channel@0.3.34
	futures-core@0.3.34
	futures-io@0.3.34
	futures-macro@0.3.34
	futures-sink@0.3.34
	futures-task@0.3.34
	futures-util@0.3.34
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.3
	half@2.7.1
	heck@0.5.0
	hf-hub@0.4.3
	http-body-util@0.1.5
	http-body@1.1.0
	http@1.5.0
	httparse@1.10.1
	hyper-rustls@0.27.9
	hyper-util@0.1.20
	hyper@1.11.1
	icu_collections@2.3.0
	icu_locale_core@2.3.0
	icu_normalizer@2.3.0
	icu_normalizer_data@2.3.0
	icu_properties@2.3.0
	icu_properties_data@2.3.0
	icu_provider@2.3.1
	ident_case@1.0.1
	idna@1.1.0
	idna_adapter@1.2.2
	indicatif@0.17.11
	indicatif@0.18.6
	ipnet@2.12.2
	is_terminal_polyfill@1.70.2
	itertools@0.10.5
	itertools@0.13.0
	itertools@0.14.0
	itoa@1.0.18
	jiff-core@0.1.0
	jiff-static@0.2.35
	jiff@0.2.35
	js-sys@0.3.104
	js-sys@0.3.105
	lazy_static@1.5.0
	libc@0.2.189
	libredox@0.1.23
	linux-raw-sys@0.12.1
	litemap@0.8.3
	log@0.4.34
	lru-slab@0.1.2
	macro_rules_attribute-proc_macro@0.2.3
	macro_rules_attribute@0.2.3
	matrixmultiply@0.3.11
	memchr@2.8.3
	minimal-lexical@0.2.1
	miniz_oxide@0.9.1
	mio@1.2.3
	monostate-impl@0.1.18
	monostate@0.1.18
	ndarray@0.16.1
	ndarray@0.17.2
	nom@7.1.3
	nu-ansi-term@0.50.3
	num-complex@0.4.6
	num-integer@0.1.47
	num-traits@0.2.19
	number_prefix@0.4.0
	numpy@0.29.0
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	onig@6.5.3
	onig_sys@69.9.3
	oorandom@11.1.5
	option-ext@0.2.0
	paste@1.0.15
	pastey@0.2.3
	percent-encoding@2.3.2
	pin-project-lite@0.2.17
	pkg-config@0.3.34
	plotters-backend@0.3.7
	plotters-svg@0.3.7
	plotters@0.3.7
	portable-atomic-util@0.2.7
	portable-atomic@1.15.0
	potential_utf@0.1.6
	ppv-lite86@0.2.21
	proc-macro2@1.0.107
	pyo3-async-runtimes@0.29.0
	pyo3-build-config@0.29.2
	pyo3-ffi@0.29.2
	pyo3-macros-backend@0.29.2
	pyo3-macros@0.29.2
	pyo3@0.29.2
	quinn-proto@0.11.17
	quinn-udp@0.5.15
	quinn@0.11.11
	quote@1.0.47
	r-efi@5.3.0
	r-efi@6.0.0
	rand@0.10.2
	rand@0.9.5
	rand_chacha@0.9.0
	rand_core@0.10.1
	rand_core@0.9.5
	rand_pcg@0.10.2
	rawpointer@0.2.1
	rayon-cond@0.4.0
	rayon-core@1.13.0
	rayon@1.12.0
	redox_users@0.5.2
	regex-automata@0.4.18
	regex-syntax@0.8.11
	regex@1.13.1
	reqwest@0.12.28
	ring@0.17.14
	rustc-hash@2.1.3
	rustix@1.1.4
	rustls-pki-types@1.15.1
	rustls-webpki@0.103.15
	rustls@0.23.44
	rustversion@1.0.23
	ryu@1.0.23
	same-file@1.0.6
	serde@1.0.229
	serde_core@1.0.229
	serde_derive@1.0.229
	serde_json@1.0.151
	serde_urlencoded@0.7.1
	sharded-slab@0.1.7
	shlex@2.0.1
	signal-hook-registry@1.4.8
	simd-adler32@0.3.10
	slab@0.4.12
	smallvec@1.16.0
	socket2@0.6.5
	socks@0.3.4
	spm_precompiled@0.1.4
	stable_deref_trait@1.2.1
	static_assertions@1.1.0
	strsim@0.11.1
	subtle@2.6.1
	syn@2.0.119
	syn@3.0.4
	syn@3.0.5
	sync_wrapper@1.0.2
	synstructure@0.13.2
	target-lexicon@0.13.5
	tempfile@3.27.0
	thiserror-impl@2.0.20
	thiserror@2.0.20
	thread_local@1.1.10
	tinystr@0.8.4
	tinytemplate@1.2.1
	tinyvec@1.13.2
	tinyvec_macros@0.1.1
	tokio-macros@2.7.2
	tokio-rustls@0.26.5
	tokio-util@0.7.19
	tokio@1.53.1
	tower-http@0.6.11
	tower-layer@0.3.3
	tower-service@0.3.3
	tower@0.5.3
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing-log@0.2.0
	tracing-subscriber@0.3.23
	tracing@0.1.44
	try-lock@0.2.5
	unicode-ident@1.0.24
	unicode-normalization-alignments@0.1.12
	unicode-segmentation@1.13.3
	unicode-width@0.2.2
	unicode_categories@0.1.1
	unit-prefix@0.5.2
	untrusted@0.9.0
	ureq@2.12.1
	url@2.5.8
	utf8_iter@1.0.4
	utf8parse@0.2.2
	valuable@0.1.1
	version_check@0.9.5
	walkdir@2.5.0
	want@0.3.1
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.4+wasi-0.2.12
	wasm-bindgen-futures@0.4.78
	wasm-bindgen-macro-support@0.2.127
	wasm-bindgen-macro-support@0.2.128
	wasm-bindgen-macro@0.2.127
	wasm-bindgen-macro@0.2.128
	wasm-bindgen-shared@0.2.127
	wasm-bindgen-shared@0.2.128
	wasm-bindgen@0.2.127
	wasm-bindgen@0.2.128
	wasm-streams@0.4.2
	web-sys@0.3.105
	web-time@1.1.0
	webpki-roots@0.26.11
	webpki-roots@1.0.9
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-link@0.2.1
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
	wit-bindgen@0.57.1
	writeable@0.6.4
	yoke-derive@0.8.2
	yoke@0.8.3
	zerocopy-derive@0.8.56
	zerocopy-derive@0.8.57
	zerocopy@0.8.56
	zerocopy@0.8.57
	zerofrom-derive@0.1.7
	zerofrom@0.1.8
	zeroize@1.9.0
	zerotrie@0.2.5
	zerovec-derive@0.11.6
	zerovec@0.11.8
	zlib-rs@0.6.7
	zmij@1.0.23
"

inherit cargo distutils-r1

DESCRIPTION="Implementation of today's most used tokenizers"
HOMEPAGE="https://github.com/huggingface/tokenizers"
SRC_URI="
	https://github.com/huggingface/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="Apache-2.0"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="dev-libs/oniguruma"
BDEPEND="
	test? ( sci-ml/datasets[${PYTHON_SINGLE_USEDEP}] )
	$(python_gen_cond_dep '
		dev-python/setuptools-rust[${PYTHON_USEDEP}]
	')
"

EPYTEST_PLUGINS=( )
distutils_enable_tests pytest

QA_FLAGS_IGNORED=".*/site-packages/tokenizers/.*so"

src_unpack() {
	cargo_src_unpack
}

pkg_setup() {
	python-single-r1_pkg_setup
	rust_pkg_setup
}

src_prepare() {
	default
	cd bindings/python
	eapply "${FILESDIR}"/${PN}-0.21.2-test.patch
	distutils-r1_src_prepare
}

src_configure() {
	cd tokenizers
	cargo_src_configure
	cd ../bindings/python
	distutils-r1_src_configure
}

src_compile() {
	export RUSTONIG_SYSTEM_LIBONIG=1
	cd tokenizers
	cargo_src_compile
	cd ../bindings/python
	distutils-r1_src_compile
}

src_test() {
	cd bindings/python
	local -x EPYTEST_IGNORE=( benches/test_tiktoken.py )
	local -x EPYTEST_DESELECT=(
		tests/bindings/test_encoding.py::TestEncoding::test_char_to_token
		tests/bindings/test_encoding.py::TestEncoding::test_char_to_word
		tests/bindings/test_encoding.py::TestEncoding::test_invalid_truncate_direction
		tests/bindings/test_encoding.py::TestEncoding::test_n_sequences
		tests/bindings/test_encoding.py::TestEncoding::test_sequence_ids
		tests/bindings/test_encoding.py::TestEncoding::test_token_to_chars
		tests/bindings/test_encoding.py::TestEncoding::test_token_to_sequence
		tests/bindings/test_encoding.py::TestEncoding::test_token_to_word
		tests/bindings/test_encoding.py::TestEncoding::test_truncation
		tests/bindings/test_encoding.py::TestEncoding::test_word_to_chars
		tests/bindings/test_encoding.py::TestEncoding::test_word_to_tokens
		tests/bindings/test_models.py::TestWordLevel::test_instantiate
		tests/bindings/test_models.py::TestWordPiece::test_instantiate
		tests/bindings/test_processors.py::TestByteLevelProcessing::test_processing
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_async_methods_existence
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_basic_encoding
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_concurrency
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_decode
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_encode
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_error_handling
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_large_batch
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_numpy_inputs
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_various_input_formats
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_performance_comparison
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_with_special_tokens
		tests/bindings/test_tokenizer.py::TestAsyncTokenizer::test_with_truncation_padding
		tests/bindings/test_tokenizer.py::TestTokenizer::test_encode_add_special_tokens
		tests/bindings/test_tokenizer.py::TestTokenizer::test_encode_formats
		tests/bindings/test_tokenizer.py::TestTokenizer::test_encode_special_tokens
		tests/bindings/test_tokenizer.py::TestTokenizer::test_decode_skip_special_tokens
		tests/bindings/test_tokenizer.py::TestTokenizer::test_decode_stream_fallback
		tests/bindings/test_tokenizer.py::TestTokenizer::test_from_pretrained
		tests/bindings/test_tokenizer.py::TestTokenizer::test_from_pretrained_revision
		tests/bindings/test_tokenizer.py::TestTokenizer::test_splitting
		tests/bindings/test_trainers.py::TestUnigram::test_continuing_prefix_trainer_mismatch
		tests/bindings/test_trainers.py::TestUnigram::test_train
		tests/bindings/test_trainers.py::TestUnigram::test_train_parallelism_with_custom_pretokenizer
		tests/documentation/test_pipeline.py::TestPipeline::test_bert_example
		tests/documentation/test_pipeline.py::TestPipeline::test_pipeline
		tests/documentation/test_quicktour.py::TestQuicktour::test_quicktour
		tests/documentation/test_tutorial_train_from_iterators.py::TestTrainFromIterators::test_datasets
		tests/documentation/test_tutorial_train_from_iterators.py::TestTrainFromIterators::test_gzip
		tests/implementations/test_byte_level_bpe.py::TestByteLevelBPE::test_add_prefix_space
		tests/implementations/test_byte_level_bpe.py::TestByteLevelBPE::test_basic_encode
		tests/implementations/test_byte_level_bpe.py::TestByteLevelBPE::test_lowerspace
		tests/implementations/test_byte_level_bpe.py::TestByteLevelBPE::test_multiprocessing_with_parallelism
		tests/implementations/test_bert_wordpiece.py::TestBertWordPieceTokenizer::test_basic_encode
		tests/implementations/test_bert_wordpiece.py::TestBertWordPieceTokenizer::test_multiprocessing_with_parallelism
		tests/implementations/test_char_bpe.py::TestCharBPETokenizer::test_basic_encode
		tests/implementations/test_char_bpe.py::TestCharBPETokenizer::test_decoding
		tests/implementations/test_char_bpe.py::TestCharBPETokenizer::test_lowercase
		tests/implementations/test_char_bpe.py::TestCharBPETokenizer::test_multiprocessing_with_parallelism
		tests/test_serialization.py::TestSerialization::test_full_serialization_albert
		tests/test_serialization.py::TestSerialization::test_str_big
	)
	distutils-r1_src_test
}

src_install() {
	cd tokenizers
	cd ../bindings/python
	distutils-r1_src_install
}
