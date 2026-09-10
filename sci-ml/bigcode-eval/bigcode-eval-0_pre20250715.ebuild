# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="Framework for evaluating autoregressive code generation language models"
HOMEPAGE="https://github.com/bigcode-project/bigcode-evaluation-harness"

# No release since 0.1.0; pin main as of 2025-07-15.
EGIT_COMMIT="8fc5bae6479c4fbbb28c3f8b644f6a15b3f3b5bd"
SRC_URI="https://github.com/bigcode-project/bigcode-evaluation-harness/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/bigcode-evaluation-harness-${EGIT_COMMIT}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Snapshot requirements, except pyext removed below.
RDEPEND="
	>=sci-ml/accelerate-0.13.2[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/datasets-2.6.1[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/evaluate-0.3.0[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/huggingface_hub-0.11.1[${PYTHON_SINGLE_USEDEP}]
	>=sci-ml/transformers-4.25.1[${PYTHON_SINGLE_USEDEP}]
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/mosestokenizer[${PYTHON_USEDEP}]
		>=dev-python/fsspec-2023.12.2[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	# pyext is only dynamically used by ds1000 and fails on Python 3.11+.
	# Upstream CI uses mosestokenizer 1.2 with a compatible API.
	sed -i \
		-e '/^pyext\b/d' \
		-e 's/^mosestokenizer==.*/mosestokenizer/' \
		requirements.txt || die
	# Supply the snapshot version; upstream defaults to 0.0.0.
	sed -i '/^setup(/a\\    version="0.dev20250715",' setup.py || die
	distutils-r1_src_prepare
}

python_install_all() {
	distutils-r1_python_install_all

	# Install upstream's clone-and-run driver under /usr/share with a wrapper.
	insinto /usr/share/bigcode-evaluation-harness
	doins main.py

	cat > "${T}/bigcode-eval" <<-EOF
		#!/bin/sh
		exec python /usr/share/bigcode-evaluation-harness/main.py "\$@"
	EOF
	dobin "${T}/bigcode-eval"
}
