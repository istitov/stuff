# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=maturin
# PyO3 0.25 refuses CPython newer than 3.14. verified 2026-10-05
PYTHON_COMPAT=( python3_{12..14} )

RUST_MIN_VER="1.88.0"
CRATES="
	aho-corasick@1.1.4
	android_system_properties@0.1.5
	anyhow@1.0.102
	autocfg@1.5.0
	base64@0.22.1
	bit-set@0.5.3
	bit-vec@0.6.3
	block-buffer@0.10.4
	bs58@0.5.1
	bstr@1.12.1
	bumpalo@3.20.2
	cc@1.2.62
	cfg-if@1.0.4
	chrono@0.4.44
	core-foundation-sys@0.8.7
	cpufeatures@0.2.17
	crypto-common@0.1.7
	darling@0.23.0
	darling_core@0.23.0
	darling_macro@0.23.0
	deranged@0.5.8
	diff@0.1.13
	digest@0.10.7
	dyn-clone@1.0.20
	equivalent@1.0.2
	fancy-regex@0.13.0
	find-msvc-tools@0.1.9
	futures-core@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	generic-array@0.14.7
	getrandom@0.3.4
	hashbrown@0.12.3
	hashbrown@0.17.1
	heck@0.5.0
	hex@0.4.3
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	ident_case@1.0.1
	indexmap@1.9.3
	indexmap@2.14.0
	indoc@2.0.7
	itoa@1.0.18
	jobserver@0.1.34
	js-sys@0.3.98
	libc@0.2.186
	log@0.4.29
	memchr@2.8.0
	memoffset@0.9.1
	num-conv@0.2.1
	num-traits@0.2.19
	once_cell@1.21.4
	pin-project-lite@0.2.17
	pkg-config@0.3.33
	portable-atomic@1.13.1
	powerfmt@0.2.0
	pretty_assertions@1.4.1
	proc-macro2@1.0.106
	pyo3-build-config@0.25.1
	pyo3-ffi@0.25.1
	pyo3-macros-backend@0.25.1
	pyo3-macros@0.25.1
	pyo3@0.25.1
	quote@1.0.45
	r-efi@5.3.0
	ref-cast-impl@1.0.25
	ref-cast@1.0.25
	regex-automata@0.4.14
	regex-syntax@0.8.10
	rustc-hash@1.1.0
	rustversion@1.0.22
	schemars@0.9.0
	schemars@1.2.1
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.149
	serde_with@3.20.0
	serde_with_macros@3.20.0
	sha2@0.10.9
	shlex@1.3.0
	slab@0.4.12
	strsim@0.11.1
	syn@2.0.117
	target-lexicon@0.13.5
	thiserror-impl@2.0.18
	thiserror@2.0.18
	time-core@0.1.8
	time-macros@0.2.27
	time@0.3.47
	tinyvec@1.11.0
	tinyvec_macros@0.1.1
	typenum@1.20.0
	unicode-ident@1.0.24
	unindent@0.2.4
	version_check@0.9.5
	wasip2@1.0.3+wasi-0.2.9
	wasm-bindgen-macro-support@0.2.121
	wasm-bindgen-macro@0.2.121
	wasm-bindgen-shared@0.2.121
	wasm-bindgen@0.2.121
	windows-core@0.62.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-result@0.4.1
	windows-strings@0.5.1
	wit-bindgen@0.57.1
	yansi@1.0.1
	zmij@1.0.21
	zstd-safe@7.2.4
	zstd-sys@2.0.16+zstd.1.5.7
	zstd@0.13.3
"

inherit cargo distutils-r1

DESCRIPTION="Response format library for gpt-oss, a fork of openai-harmony"
HOMEPAGE="
	https://github.com/oss-harmony/harmony
	https://pypi.org/project/oss-harmony/
"
SRC_URI="
	https://github.com/oss-harmony/harmony/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/harmony-${PV}"

LICENSE="Apache-2.0"
# Dependent crate licenses
LICENSE+=" Apache-2.0-with-LLVM-exceptions MIT Unicode-3.0"
SLOT="0"
KEYWORDS="~amd64"

# Both install the openai_harmony module; this fork compiles the
# tiktoken vocabularies in instead of downloading them.
RDEPEND="
	!dev-python/openai-harmony
	>=dev-python/pydantic-2.11.7[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_test() {
	cargo_src_test --all-targets --all-features
	cargo_src_test --doc
	distutils-r1_src_test
}

# Rust extension does not expose C/C++ flag provenance to QA.
QA_FLAGS_IGNORED="usr/lib/python3.*/site-packages/openai_harmony/openai_harmony.abi3.so"
