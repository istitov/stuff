# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-r1

DESCRIPTION="Shim providing the tccbox Python API over system dev-lang/tcc"
HOMEPAGE="https://github.com/metab0t/tccbox"
S="${WORKDIR}"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	>=dev-lang/tcc-0.9.27_p20251027
"

# Upstream tccbox bundles a prebuilt TCC inside the wheel; no sdist is
# published. This shim exposes the same three-function API
# (tcc_bin_path, tcc_lib_dir, tcc_include_dir) pointing at the system
# dev-lang/tcc install instead of a bundled copy.

src_unpack() {
	mkdir -p "${S}/tccbox" || die
}

src_prepare() {
	default

	local tccdir="/usr/$(get_libdir)/tcc"

	cat > "${S}/tccbox/__init__.py" <<-EOF || die
		"""tccbox shim backed by Gentoo's dev-lang/tcc install."""
		import os

		_TCC_BIN = "/usr/bin/tcc"
		_TCC_DIST = "${tccdir}"

		def tcc_bin_path():
		    return _TCC_BIN

		def tcc_lib_dir():
		    return _TCC_DIST

		def tcc_include_dir():
		    return os.path.join(_TCC_DIST, "include")
	EOF

	cat > "${S}/tccbox/__main__.py" <<-'EOF' || die
		import os
		import sys

		from . import tcc_bin_path

		os.execv(tcc_bin_path(), [tcc_bin_path(), *sys.argv[1:]])
	EOF
}

src_install() {
	python_foreach_impl python_domodule tccbox
}
