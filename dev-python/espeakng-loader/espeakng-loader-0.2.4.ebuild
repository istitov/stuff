# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-r1

DESCRIPTION="Thin Gentoo replacement for espeakng-loader (system-paths drop-in)"
HOMEPAGE="
	https://github.com/thewh1teagle/espeakng-loader
	https://pypi.org/project/espeakng-loader/
"
# No SRC_URI: upstream's PyPI distribution is wheels-only with
# bundled libespeak-ng.so binaries — Gentoo-hostile vendoring. Our
# module is hand-written in files/ to match upstream's tiny API
# surface (4 functions) but return system paths.
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	app-accessibility/espeak-ng
"

src_unpack() {
	mkdir -p "${S}/espeakng_loader" || die
	cp "${FILESDIR}/__init__.py" "${S}/espeakng_loader/__init__.py" || die

	# Bake system paths into the module at unpack time.
	local lib_path="/usr/$(get_libdir)/libespeak-ng.so.1"
	local data_path="/usr/share/espeak-ng-data"
	sed -i \
		-e "s|@LIBESPEAK_NG@|${lib_path}|" \
		-e "s|@ESPEAK_NG_DATA@|${data_path}|" \
		"${S}/espeakng_loader/__init__.py" || die
}

src_install() {
	python_foreach_impl python_domodule espeakng_loader
}
