# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1

CRATES="
	allocator-api2@0.2.21
	bitflags@2.13.0
	block2@0.6.2
	cfg-if@1.0.4
	dispatch2@0.3.1
	equivalent@1.0.2
	errno@0.3.14
	fastrand@2.4.1
	foldhash@0.2.0
	getrandom@0.4.3
	hashbrown@0.16.1
	heck@0.5.0
	itoa@1.0.18
	libc@0.2.186
	linux-raw-sys@0.12.1
	memchr@2.8.2
	memmap2@0.9.11
	objc2-core-foundation@0.3.2
	objc2-encode@4.1.0
	objc2-foundation@0.3.2
	objc2-metal@0.3.2
	objc2@0.6.4
	once_cell@1.21.4
	portable-atomic@1.13.1
	proc-macro2@1.0.106
	pyo3-build-config@0.28.3
	pyo3-ffi@0.28.3
	pyo3-macros-backend@0.28.3
	pyo3-macros@0.28.3
	pyo3@0.28.3
	quote@1.0.46
	r-efi@6.0.0
	rustix@1.1.4
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.150
	syn@2.0.118
	target-lexicon@0.13.5
	tempfile@3.27.0
	unicode-ident@1.0.24
	windows-link@0.2.1
	windows-sys@0.61.2
	zmij@1.0.21
"

DISTUTILS_USE_PEP517=maturin
PYTHON_COMPAT=( python3_{10..14} )
RUST_MIN_VER="1.85.0"

inherit distutils-r1 cargo

DESCRIPTION="Simple, safe way to store and distribute tensors"
HOMEPAGE="
	https://pypi.org/project/safetensors/
	https://huggingface.co/
"
SRC_URI="https://github.com/huggingface/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.gh.tar.gz
	${CARGO_CRATE_URIS}
"

S="${WORKDIR}"/${P}/bindings/python

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

QA_FLAGS_IGNORED="usr/lib/.*"
RESTRICT="test" #depends on single pkg ( pytorch )

BDEPEND="
	dev-python/setuptools-rust[${PYTHON_USEDEP}]
	test? (
		dev-python/h5py[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare
	rm tests/test_{tf,paddle,flax}_comparison.py || die
	rm benches/test_{pt,tf,paddle,flax}.py || die
}

src_configure() {
	cargo_src_configure
	distutils-r1_src_configure
}

python_compile() {
	cargo_src_compile
	distutils-r1_python_compile
}

src_compile() {
	distutils-r1_src_compile
}

src_install() {
	distutils-r1_src_install
}
