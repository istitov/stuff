# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

# The PDFium build pypdfium2 pins (autorelease/record.json).
PDFIUM_BUILD=8138

DESCRIPTION="Python bindings to PDFium"
HOMEPAGE="
	https://github.com/pypdfium2-team/pypdfium2
	https://pypi.org/project/pypdfium2/
"
# ::gentoo has no PDFium, and building it needs Chromium's gn/gclient tree, so
# use the pdfium-binaries build that upstream's own wheels bundle.
SRC_URI+="
	amd64? (
		https://github.com/bblanchon/pdfium-binaries/releases/download/chromium%2F${PDFIUM_BUILD}/pdfium-linux-x64.tgz
			-> pdfium-binaries-${PDFIUM_BUILD}-linux-x64.tgz
	)
"

# pypdfium2 itself is Apache-2.0 OR BSD-3-Clause.
LICENSE="|| ( Apache-2.0 BSD )"
# libpdfium.so and the libraries built into it, from the tarball's licenses/:
# pdfium, abseil, highway, dragonbox, fast_float, freetype, harfbuzz, icu,
# lcms, libjpeg-turbo, openjpeg, libpng, simdutf, zlib, llvm-libc,
# pdfium-binaries (MIT) and AGG 2.3, whose notice-only grant is closest to
# HPND. verified 2026-11-17
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Boost-1.0
	|| ( FTL GPL-2+ ) HPND IJG ISC MIT Old-MIT Unicode-3.0 ZLIB libpng2
"
SLOT="0"
KEYWORDS="-* ~amd64"

QA_PREBUILT="usr/lib/python3*/site-packages/pypdfium2_raw/libpdfium.so"

BDEPEND="
	test? (
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_unpack() {
	# The PDFium tarball is staged in src_prepare.
	unpack "${P}.tar.gz"
}

src_prepare() {
	distutils-r1_src_prepare

	# Unpack the tarball the way setupsrc/update.py does after a download,
	# so setup.py finds a cached binary of the pinned build and fetches
	# nothing; it then generates the ctypes bindings from its headers.
	cp "${DISTDIR}/pdfium-binaries-${PDFIUM_BUILD}-linux-x64.tgz" \
		"${T}/pdfium.tgz" || die
	mkdir -p data/linux_x64 || die
	python_setup
	"${EPYTHON}" - "${T}/pdfium.tgz" "${PDFIUM_BUILD}" <<-EOF || die
		import sys
		from pathlib import Path
		sys.path.insert(0, "setupsrc")
		import update
		update.do_extract({"linux_x64": Path(sys.argv[1])}, int(sys.argv[2]), ())
	EOF
	[[ -f data/linux_x64/libpdfium.so ]] || die "pdfium staging failed"
}

python_compile() {
	local -x PDFIUM_PLATFORM="linux_x64:${PDFIUM_BUILD}"
	distutils-r1_python_compile
}

python_test() {
	# Import the installed package, not the source tree. The rendering and
	# saving tests write into tests/output, which the sdist omits; with it,
	# 177 pass and 1 skips. verified 2026-11-17
	rm -rf src || die
	mkdir -p tests/output || die
	epytest
}
