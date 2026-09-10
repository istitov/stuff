# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

GNOME2_LA_PUNT="yes"
_PYTHON_ALLOW_PY27=1
PYTHON_COMPAT=( python2_7 )

inherit autotools gnome2 python-r1_py2
DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="https://pygobject.gnome.org"

LICENSE="LGPL-2.1+"
SLOT="2"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="examples libffi test"
RESTRICT="!test? ( test )"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

COMMON_DEPEND=">=dev-libs/glib-2.24.0:2
	libffi? ( dev-libs/libffi:= )
	dev-lang/python:2.7
"
DEPEND="${COMMON_DEPEND}
	dev-build/gtk-doc-am
	virtual/pkgconfig
	test? (
		media-fonts/font-cursor-misc
		media-fonts/font-misc-misc )
"
RDEPEND="${COMMON_DEPEND}"

src_prepare() {
	# Fix code-generator FHS path (upstream bug 535524).
	eapply "${FILESDIR}/${PN}-2.28.3-fix-codegen-location.patch"

	# Honor disabled tests (upstream bug 226345).
	eapply "${FILESDIR}/${PN}-2.28.3-make_check.patch"

	# Support multiple Python versions (upstream bug 648292).
	eapply "${FILESDIR}/${PN}-2.28.3-support_multiple_python_versions.patch"

	eapply "${FILESDIR}/${P}-disable-failing-tests.patch"

	# Skip introspection tests when the feature is disabled.
	eapply "${FILESDIR}/${P}-tests-no-introspection.patch"

	# Avoid set_qdata on NULL objects.
	eapply "${FILESDIR}/${P}-set_qdata.patch"
	# Match GIO flag types from GLib.
	eapply "${FILESDIR}/${P}-gio-types-2.32.patch"

	# Support GLib 2.36+ (Gentoo bug 486602).
	eapply "${FILESDIR}/${P}-glib-2.36-class_init.patch"

	sed -i \
		-e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' \
		-e 's:AM_PROG_CC_STDC:AC_PROG_CC:' \
		configure.ac || die

	eautoreconf
	gnome2_src_prepare

	python_copy_sources

	convert_shebangs() {
		# Preserve an unconverted copy for python_doscript.
		cp codegen/codegen.py pygobject-codegen-2.0
		sed -e "s%#! \?/usr/bin/env python%#!${PYTHON}%" \
			-i codegen/*.py || die "shebang convertion failed"
	}
	python_foreach_impl run_in_build_dir convert_shebangs
}

src_configure() {
	local myconf
	DOCS="AUTHORS ChangeLog* NEWS README"
	# pygobject:3 provides introspection support.
	myconf="${myconf}
		--enable-debug=no
		--disable-introspection
		--disable-cairo
		$(use_with libffi ffi)"

	python_foreach_impl run_in_build_dir gnome2_src_configure ${myconf}
}

src_compile() {
	python_foreach_impl run_in_build_dir gnome2_src_compile
}

# Multi-ABI tests return 1 even when successful.
src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	# Avoid gvfs cleanup failures.
	export GIO_USE_VFS="local"

	testing() {
		export XDG_CACHE_HOME="${T}/${EPYTHON}"
		run_in_build_dir Xemake -j1 check
		unset XDG_CACHE_HOME
	}
	python_foreach_impl testing
	unset GIO_USE_VFS
}

src_install() {
	installing() {
		local f prefixed_sitedir

		gnome2_src_install

		python_doscript pygobject-codegen-2.0

		# Share one pygobject-codegen-2.0 script across implementations.
		prefixed_sitedir=$(python_get_sitedir)
		dosym "${prefixed_sitedir#${EPREFIX}}/gtk-2.0/codegen/codegen.py" \
			"/usr/lib/python-exec/${EPYTHON}/pygobject-codegen-2.0"
	}
	python_foreach_impl run_in_build_dir installing

	if use examples; then
		dodoc -r examples
	fi
}

run_in_build_dir() {
	pushd "${BUILD_DIR}" > /dev/null || die
	"$@"
	popd > /dev/null
}
