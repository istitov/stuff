# $Header: $

EAPI=5

EGIT_BRANCH="master"
EGIT_REPO_URI="
    https://github.com/snavely/bundler_sfm.git
"

inherit eutils git-r3

DESCRIPTION="Bundler is a structure-from-motion system for unordered image collections."
HOMEPAGE="https://github.com/snavely/bundler_sfm"

IUSE="-ceres"

SLOT="0"
KEYWORDS="amd64"

RDEPEND="
    media-gfx/jhead
    ceres? ( sci-libs/ceres-solver )
    virtual/lapack
    virtual/blas
    virtual/cblas
"
DEPEND="$RDEPEND
	media-gfx/jhead
	"


src_prepare() {
    #epatch "${FILESDIR}"/extract_focal.patch
    epatch "${FILESDIR}"/BASE_PATH.patch
    if use ceres; then
	    epatch "${FILESDIR}"/ceres.patch
    fi

    mv bin orig_bin || die
    mkdir bin || die
    rm -r vc++ orig_bin/*.dll || die
}

src_compile() {
    emake clean
    emake OPTFLAGS="$CFLAGS $LDFLAGS" -C lib/5point
    emake -C lib/ann_1.1_char/src targets "ANNLIB = libANN_char.so" "C++ = g++" CFLAGS="$CFLAGS -fPIC" 'MAKELIB = g++ -shared -o ' "RANLIB = true"
    emake OPTFLAGS="$CFLAGS $LDFLAGS" -C lib/imagelib
    emake OPTFLAGS="$CFLAGS $LDFLAGS" -C lib/matrix
    emake OPTFLAGS="$CFLAGS $LDFLAGS" -C lib/sba-1.5
    emake OPTFLAGS="$CFLAGS $LDFLAGS" -C lib/sfm-driver
    emake OPTFLAGS="$CFLAGS $LDFLAGS" -C lib/minpack
    emake OPTFLAGS="$CFLAGS $LDFLAGS" -C src
}

src_install() {
    # Эта функция нуждается в доработке - возможно устанавливаем не всё, что нужно.

    dobin RunBundler.sh
    dobin orig_bin/*
    cd bin || die
    dobin Bundle2Ply Bundle2PMVS Bundle2Vis bundler KeyMatchFull RadialUndistort
    dolib.so libANN_char.so
}
