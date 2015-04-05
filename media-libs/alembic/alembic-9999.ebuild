# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alembic/alembic-9999.ebuild,v 0.1 2014/12/05 11:41:48 brothermechanic Exp $

EAPI=5

PYTHON_COMPAT=( python3_4 )

inherit cmake-utils eutils python python-single-r1 mercurial flag-o-matic

DESCRIPTION="Open Interchange Format for Computer Graphics"
HOMEPAGE="https://code.google.com/p/alembic/"
EHG_REPO_URI="https://code.google.com/p/alembic/"
EHG_REVISION="1_05_01"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="python"

RDEPEND="dev-libs/boost[static-libs]
	media-libs/freeglut
	media-libs/openexr
	media-libs/ilmbase
	python? ( media-libs/python-pyilmbase )
	sci-libs/hdf5
	"
DEPEND="${RDEPEND}"

#S=${WORKDIR}/${P}

src_configure() {
    append-flags --with-pic -fPIC
    configuration() {
        "$(PYTHON)" build/bootstrap/alembic_bootstrap.py \
            --bindir="${EPREFIX}/usr/bin" \
            --destdir="${EPREFIX}$(python_get_sitedir)"
    }
    python_execute_function -s configuration

    local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DBUILD_STATIC_LIBS=ON
		
		$(cmake-utils_use_use truetype freetype)
		$(cmake-utils_use_use colorio OCIO)
		$(cmake-utils_use_use opencv)
		$(cmake-utils_use_use opengl)
		$(cmake-utils_use_use jpeg2k OPENJPEG)
		$(cmake-utils_use_use python)
		$(cmake-utils_use_use qt4 QT)
		$(cmake-utils_use_use tbb)
		$(cmake-utils_use_use ssl OPENSSL)
		$(cmake-utils_use_use gif)
		)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}
