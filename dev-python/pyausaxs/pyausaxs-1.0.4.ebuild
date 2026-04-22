# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-r1

DESCRIPTION="Stub pyausaxs exposing AUSAXS so SasView falls back to its Python SANS path"
HOMEPAGE="https://github.com/AUSAXS/pyAUSAXS"
S="${WORKDIR}"

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}"

# Upstream pyausaxs wraps the AUSAXS C++ library and is distributed
# only as platform-specific wheels bundling a prebuilt libausaxs. This
# ebuild provides a minimal stub module: AUSAXS is importable, but
# instantiating it raises NotImplementedError. SasView's
# ausaxs_sans_debye.py already try/excepts at call time and falls back
# to its pure-Python sasview_sans_debye path, so the stub is
# functionally equivalent to "no accelerator available".

src_unpack() {
	mkdir -p "${S}/pyausaxs" || die
}

src_prepare() {
	default

	cat > "${S}/pyausaxs/__init__.py" <<-'EOF' || die
		"""Stub pyausaxs module (Gentoo overlay: stuff).

		Upstream pyausaxs is a binary-only Python wrapper around the
		AUSAXS C++ library. This stub exposes the AUSAXS symbol that
		SasView imports unconditionally; any use of AUSAXS raises,
		triggering SasView's runtime fallback to its pure-Python
		scattering calculator.
		"""

		class AUSAXS:
		    def __init__(self, *args, **kwargs):
		        raise NotImplementedError(
		            "pyausaxs is not installed (Gentoo stub from overlay 'stuff'); "
		            "SasView will fall back to its Python implementation."
		        )

		__all__ = ["AUSAXS"]
	EOF
}

src_install() {
	python_foreach_impl python_domodule pyausaxs
}
