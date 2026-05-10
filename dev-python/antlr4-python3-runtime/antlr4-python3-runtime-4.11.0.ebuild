# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_P=antlr4-${PV}
DESCRIPTION="Python 3 runtime for ANTLR"
HOMEPAGE="
	https://www.antlr.org/
	https://github.com/antlr/antlr4/
	https://pypi.org/project/antlr4-python3-runtime/
"
SRC_URI="
	https://github.com/antlr/antlr4/archive/${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S="${WORKDIR}/${MY_P}/runtime/Python3"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

# Older 4.11.0 kept alongside ::gentoo's 4.13.2 because lm-eval's math
# task does `assert version("antlr4-python3-runtime").startswith("4.11")`
# at task-load (lm_eval/tasks/minerva_math/utils.py); upstream
# math_verify[antlr4_11_0] / latex2sympy2_extended[antlr4_11_0] also pin
# to 4.11.0 exactly. Consumers in ::gentoo (moto, coq) leave the version
# unpinned (verified 2026-05-11), so taking the downgrade is structurally
# safe across the dep graph.

src_prepare() {
	# Same assertEquals/assertEqual fix as ::gentoo's 4.13.2 ebuild,
	# upstream PR https://github.com/antlr/antlr4/pull/4593. Re-verified
	# at 4.11.0 on 2026-05-11: tests/TestIntervalSet.py contains 7
	# assertEquals usages at this tag and the post-sed test phase runs
	# 16 tests with no failures.
	sed -i -e 's:assertEquals:assertEqual:' tests/TestIntervalSet.py || die

	distutils-r1_src_prepare
}

python_test() {
	"${EPYTHON}" tests/run.py -v || die "Tests failed with ${EPYTHON}"
}
