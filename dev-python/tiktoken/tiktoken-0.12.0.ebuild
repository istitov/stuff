# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

RUST_MIN_VER="1.85.0"
CRATES="
	aho-corasick@1.1.4
	autocfg@1.5.0
	bit-set@0.5.3
	bit-vec@0.6.3
	bstr@1.12.1
	fancy-regex@0.13.0
	heck@0.5.0
	indoc@2.0.7
	libc@0.2.183
	memchr@2.8.0
	memoffset@0.9.1
	once_cell@1.21.4
	portable-atomic@1.13.1
	proc-macro2@1.0.106
	pyo3-build-config@0.26.0
	pyo3-ffi@0.26.0
	pyo3-macros-backend@0.26.0
	pyo3-macros@0.26.0
	pyo3@0.26.0
	quote@1.0.45
	regex-automata@0.4.14
	regex-syntax@0.8.10
	regex@1.12.3
	rustc-hash@2.1.1
	rustversion@1.0.22
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	syn@2.0.117
	target-lexicon@0.13.5
	unicode-ident@1.0.24
	unindent@0.2.4
"

inherit cargo distutils-r1 pypi

DESCRIPTION="A fast BPE tokeniser for use with OpenAI's models"
HOMEPAGE="
	https://github.com/openai/tiktoken
	https://pypi.org/project/tiktoken/
"
SRC_URI+="
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" Apache-2.0-with-LLVM-exceptions MIT Unicode-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-python/regex[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
"

# Tests need dev-python/blobfile (::guru-only) plus a network-fetched
# encoding cache; not worth forking blobfile for our overlay's needs.
RESTRICT="test"
