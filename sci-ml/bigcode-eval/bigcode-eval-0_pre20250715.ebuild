# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="Framework for evaluating autoregressive code generation language models"
HOMEPAGE="https://github.com/bigcode-project/bigcode-evaluation-harness"

# upstream has not tagged a release since v0.1.0 (2024-04-20); the project is
# alive but slow-moving. Pin to main HEAD as of 2025-07-15.
EGIT_COMMIT="8fc5bae6479c4fbbb28c3f8b644f6a15b3f3b5bd"
SRC_URI="https://github.com/bigcode-project/bigcode-evaluation-harness/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/bigcode-evaluation-harness-${EGIT_COMMIT}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Core deps from requirements.txt at HEAD. pyext is listed but not actually
# imported in any .py source (only by ds1000 adapter at runtime via dynamic
# code generation, which is broken on Py3.11+ regardless), so we drop it.
#
# single-impl: the entire sci-ml/* stack here is SINGLE_IMPL; only the two
# dev-python/* helpers are multi-impl, wrapped via python_gen_cond_dep.
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
	# pyext is in requirements.txt but unused in python source; it would also
	# fail to install on Py3.11+ anyway (uses inspect.getargspec at import
	# time). The `mosestokenizer==1.0.0` pin is wishful — upstream CI uses
	# 1.2.x, and the API surface bigcode touches is unchanged.
	sed -i \
		-e '/^pyext\b/d' \
		-e 's/^mosestokenizer==.*/mosestokenizer/' \
		requirements.txt || die
	distutils-r1_src_prepare
}

python_install_all() {
	distutils-r1_python_install_all

	# Ship the top-level driver script + a thin /usr/bin wrapper. Upstream
	# expects users to clone-and-run; we mirror that by installing main.py
	# under /usr/share/ and exposing it as `bigcode-eval`.
	insinto /usr/share/bigcode-evaluation-harness
	doins main.py

	cat > "${T}/bigcode-eval" <<-EOF
		#!/bin/sh
		exec python /usr/share/bigcode-evaluation-harness/main.py "\$@"
	EOF
	dobin "${T}/bigcode-eval"
}
