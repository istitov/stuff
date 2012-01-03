# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="2"

inherit eutils

DESCRIPTION="An OCR Engine that was developed at HP and now at Google"
HOMEPAGE="http://code.google.com/p/tesseract-ocr/"
SRC_URI="http://tesseract-ocr.googlecode.com/files/${P}.tar.gz
zh_trad? ( http://tesseract-ocr.googlecode.com/files/chi_tra.traineddata.gz )
zh_simp? ( http://tesseract-ocr.googlecode.com/files/chi_sim.traineddata.gz )
in? ( http://tesseract-ocr.googlecode.com/files/ind.traineddata.gz )
sv? ( http://tesseract-ocr.googlecode.com/files/swe.traineddata.gz )
ro? ( http://tesseract-ocr.googlecode.com/files/ron.traineddata.gz )
sl? ( http://tesseract-ocr.googlecode.com/files/slv.traineddata.gz )
sr? ( http://tesseract-ocr.googlecode.com/files/srp.traineddata.gz )
tl? ( http://tesseract-ocr.googlecode.com/files/tgl.traineddata.gz )
tr? ( http://tesseract-ocr.googlecode.com/files/tur.traineddata.gz )
hu? ( http://tesseract-ocr.googlecode.com/files/hun.traineddata.gz )
fi? ( http://tesseract-ocr.googlecode.com/files/fin.traineddata.gz )
it? ( http://tesseract-ocr.googlecode.com/files/ita.traineddata.gz )
nl? ( http://tesseract-ocr.googlecode.com/files/nld.traineddata.gz )
no? ( http://tesseract-ocr.googlecode.com/files/nor.traineddata.gz )
ja? ( http://tesseract-ocr.googlecode.com/files/jpn.traineddata.gz )
vi? ( http://tesseract-ocr.googlecode.com/files/vie.traineddata.gz )
es? ( http://tesseract-ocr.googlecode.com/files/spa.traineddata.gz )
uk? ( http://tesseract-ocr.googlecode.com/files/ukr.traineddata.gz )
fr? ( http://tesseract-ocr.googlecode.com/files/fra.traineddata.gz )
sk? ( http://tesseract-ocr.googlecode.com/files/slk.traineddata.gz )
ko? ( http://tesseract-ocr.googlecode.com/files/kor.traineddata.gz )
el? ( http://tesseract-ocr.googlecode.com/files/ell.traineddata.gz )
ru? ( http://tesseract-ocr.googlecode.com/files/rus.traineddata.gz )
pt? ( http://tesseract-ocr.googlecode.com/files/por.traineddata.gz )
bg? ( http://tesseract-ocr.googlecode.com/files/bul.traineddata.gz )
lv? ( http://tesseract-ocr.googlecode.com/files/lav.traineddata.gz )
lt? ( http://tesseract-ocr.googlecode.com/files/lit.traineddata.gz )
pl? ( http://tesseract-ocr.googlecode.com/files/pol.traineddata.gz )
de? ( http://tesseract-ocr.googlecode.com/files/deu.traineddata.gz )
de_frak? ( http://tesseract-ocr.googlecode.com/files/deu-frak.traineddata.gz )
da? ( http://tesseract-ocr.googlecode.com/files/dan-frak.traineddata.gz )
da_frak? ( http://tesseract-ocr.googlecode.com/files/dan.traineddata.gz )
cs? ( http://tesseract-ocr.googlecode.com/files/ces.traineddata.gz )
ca? ( http://tesseract-ocr.googlecode.com/files/cat.traineddata.gz )
en? ( http://tesseract-ocr.googlecode.com/files/eng.traineddata.gz )"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="alpha amd64 ~mips ppc ppc64 sparc x86"
IUSE="tiff examples doc zh_trad zh_simp in sv ro sl sr tl tr hu fi it nl no ja vi es uk fr sk ko el ru pt bg lv lt pl de de_frak da da_frak cs ca +en"

DEPEND="media-libs/leptonica"
RDEPEND="${DEPEND}"
pkg_pretend() {
	if ! use zh_trad && ! zh_simp && ! use in && ! use sv && ! use ro && ! use sl && ! use sr && ! use tl && ! use tr && ! use hu && ! use fi && ! use it && ! use nl && ! use no && ! use ja && ! use vi && ! use es && ! use uk && ! use fr && ! use sk && ! use ko && ! use el && ! use ru && ! use pt && ! use bg && ! use lv && ! use lt && ! use pl && ! use de && ! use de_frak && ! use da && ! use da_frak && ! use cs && ! use ca && ! use en ; then
		die "Install at least one language"
	fi
}

src_prepare() {
	# remove obsolete makefile, install target only in uppercase Makefile
	rm "${S}/java/makefile" || die "remove obsolete java makefile failed"

	# move language files to have them installed
	mv "${WORKDIR}/"*.traineddata tessdata/ || die "move language files failed"
}

src_configure() {
	./autogen.sh
	econf $(use_with tiff libtiff) \
		--disable-dependency-tracking
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	insinto /usr/share/tessdata
	for f in `ls -1 tessdata/*.traineddata`; do
		doins tessdata/`basename ${f}` || die "doins language failed"
	done

	if use doc; then
		dodoc AUTHORS ChangeLog NEWS README ReleaseNotes || die "dodoc failed"
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins eurotext.tif phototest.tif || die "doins examples failed"
	fi
}
