# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alembic/alembic-9999.ebuild,v 0.1 2014/12/05 11:41:48 brothermechanic Exp $

# TODO: replace the alembic_bootstrap.py with proper gentoo methods (cmake eclass)

EAPI=5

inherit cmake-utils eutils

DESCRIPTION="Alembic is an open framework for storing and sharing 3D geometry data that includes a C++ library, a file format, and client plugins and applications."
HOMEPAGE="http://alembic.io"
SRC_URI="https://github.com/alembic/alembic/archive/${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"
RDEPEND=""
DEPEND=">=dev-util/cmake-2.8
	>=dev-libs/boost-1.44
	>=media-libs/ilmbase-1.0.1
	>=sci-libs/hdf5-1.8.7
	media-libs/pyilmbase
	doc? ( >=app-doc/doxygen-1.7.3 )"
