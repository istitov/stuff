# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python2_7 )
_PYTHON_ALLOW_PY27=1
PYTHON_REQ_USE="threads(+)"
DISTUTILS_OPTIONAL=1

FORTRAN_NEEDED=lapack

inherit distutils-r1_py2 flag-o-matic fortran-2 multiprocessing pypi toolchain-funcs

MY_PN="numpy"
DOC_PV="1.16.6"

DESCRIPTION="Fast array and numerical python library"
HOMEPAGE="https://numpy.org/"
SRC_URI="
	$(pypi_sdist_url "${MY_PN}" "${PV}" .zip)
	doc? (
		https://numpy.org/doc/$(ver_cut 1-2 ${DOC_PV})/numpy-html.zip -> numpy-html-${DOC_PV}.zip
		https://numpy.org/doc/$(ver_cut 1-2 ${DOC_PV})/numpy-ref.pdf -> numpy-ref-${DOC_PV}.pdf
		https://numpy.org/doc/$(ver_cut 1-2 ${DOC_PV})/numpy-user.pdf -> numpy-user-${DOC_PV}.pdf
	)"
S="${WORKDIR}/${MY_PN}-${PV}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="doc lapack"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# DISTUTILS_OPTIONAL suppresses the eclass's interpreter dependency and target
# constraint; supply both explicitly. PYTHON_DEPS respects PYTHON_REQ_USE.
# verified 2026-07-27
RDEPEND="${PYTHON_DEPS}
	lapack? (
		virtual/cblas
		virtual/lapack
	)
"
DEPEND="${RDEPEND}"

BDEPEND="
	app-arch/unzip
	dev-python/setuptools-python2[${PYTHON_USEDEP}]
	lapack? ( virtual/pkgconfig )
"

EPYTHON="python2.7"

PATCHES=(
	"${FILESDIR}"/${MY_PN}-1.15.4-no-hardcode-blas.patch
	"${FILESDIR}"/numpy-1.16.5-setup.py-install-skip-build-fails.patch
)

src_unpack() {
	default
	if use doc; then
		unzip -qo "${DISTDIR}"/numpy-html-${DOC_PV}.zip -d html || die
	fi
}

pc_incdir() {
	$(tc-getPKG_CONFIG) --cflags-only-I $@ | \
		sed -e 's/^-I//' -e 's/[ ]*-I/:/g' -e 's/[ ]*$//' -e 's|^:||'
}

pc_libdir() {
	$(tc-getPKG_CONFIG) --libs-only-L $@ | \
		sed -e 's/^-L//' -e 's/[ ]*-L/:/g' -e 's/[ ]*$//' -e 's|^:||'
}

pc_libs() {
	$(tc-getPKG_CONFIG) --libs-only-l $@ | \
		sed -e 's/[ ]-l*\(pthread\|m\)\([ ]\|$\)//g' \
		-e 's/^-l//' -e 's/[ ]*-l/,/g' -e 's/[ ]*$//' \
		| tr ',' '\n' | sort -u | tr '\n' ',' | sed -e 's|,$||'
}

src_prepare() {
	default
	local BUILDDIR="py2"
	if use lapack; then
		append-ldflags "$($(tc-getPKG_CONFIG) --libs-only-other cblas lapack)"
		local incdir="${EPREFIX}"/usr/include
		local libdir="${EPREFIX}"/usr/$(get_libdir)
		cat >> site.cfg <<-EOF || die
			[blas]
			include_dirs = $(pc_incdir cblas):${incdir}
			library_dirs = $(pc_libdir cblas blas):${libdir}
			blas_libs = $(pc_libs cblas blas)
			[lapack]
			library_dirs = $(pc_libdir lapack):${libdir}
			lapack_libs = $(pc_libs lapack)
		EOF
	else
		export {ATLAS,PTATLAS,BLAS,LAPACK,MKL}=None
	fi

	export CC="$(tc-getCC) ${CFLAGS}"

	append-flags -fno-strict-aliasing

	# NumPy needs -shared except on Darwin, where the flag is invalid.
	if [[ ${CHOST} != *-darwin* ]]; then
		append-ldflags -shared
	fi

	# Avoid autodetecting and linking every available Fortran compiler.
	append-fflags -fPIC
	if use lapack; then
		NUMPY_FCONFIG="config_fc --noopt --noarch"
		# Select gfortran explicitly (Gentoo bug 335908).
		[[ $(tc-getFC) == *gfortran* ]] && NUMPY_FCONFIG+=" --fcompiler=gnu95"
	fi

	# Keep f2py unversioned; package selection handles coexistence.
	sed -i -e '/f2py_exe/s: + os\.path.*$::' numpy/f2py/setup.py || die

	# Disable fuzz tests.
	find numpy/*/tests -name '*.py' -exec sed -i \
		-e 's:def \(.*_fuzz\):def _\1:' {} + || die
	# Disable the memory- and disk-intensive large ZIP test.
	sed -i -e 's:test_large_zip:_&:' numpy/lib/tests/test_io.py || die

	python_foreach_impl _distutils-r1_copy_egg_info
}

src_compile() {
	export MAKEOPTS=-j1 #660754

	local python_makeopts_jobs=""
	python_makeopts_jobs="-j $(makeopts_jobs)"
	python_foreach_impl esetup.py build ${python_makeopts_jobs} ${NUMPY_FCONFIG}
}

src_install() {

	local mydistutilsargs=( build_src )
	python_foreach_impl distutils-r1_python_install ${NUMPY_FCONFIG}
	python_foreach_impl python_optimize

	local DOCS=( THANKS.txt )

	if use doc; then
		local HTML_DOCS=( "${WORKDIR}"/html/. )
		DOCS+=( "${DISTDIR}"/${MY_PN}-{user,ref}-${DOC_PV}.pdf )
	fi

	# Let the current Python 3 NumPy own the unversioned f2py link.
	rm "${ED}"/usr/bin/f2py || die
}
