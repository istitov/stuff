# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

# 2.4.0 is still a dev release upstream, but it is what unblocks the modern
# torch/HF stack: the 2.3.x line pinned the external antlr4-python3-runtime to
# 4.9, whose ATN serialization is binary-incompatible with the 4.11 runtime the
# tree ships (deserialize raises "Could not deserialize ATN with version 4").
# 2.4 sidesteps this by vendoring its own ANTLR 4.11.1 runtime under
# omegaconf/vendor/antlr4 and importing only from there, so the sole external
# runtime dep is PyYAML. Interpolation verified against the vendored parser
# 2026-07-04.
MY_PV="2.4.0.dev12"
DESCRIPTION="Flexible YAML-based configuration system with variable interpolation"
HOMEPAGE="
	https://github.com/omry/omegaconf
	https://pypi.org/project/omegaconf/
"
SRC_URI="$(pypi_sdist_url "${PN}" "${MY_PV}")"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/pyyaml-5.1.0[${PYTHON_USEDEP}]
"
