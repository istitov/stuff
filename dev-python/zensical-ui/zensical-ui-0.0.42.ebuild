# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Templates and browser assets for Zensical"
HOMEPAGE="
	https://zensical.org/
	https://github.com/zensical/ui
	https://pypi.org/project/zensical-ui/
"

# Bundled theme assets: Font Awesome icons CC-BY-4.0, Material Design
# icons Apache-2.0, Lucide ISC, Octicons MIT, Simple Icons CC0-1.0; the
# JS bundle carries MIT, Apache-2.0 and W3C components.
LICENSE="MIT Apache-2.0 CC-BY-4.0 CC0-1.0 ISC W3C"
SLOT="0"
KEYWORDS="~amd64"
