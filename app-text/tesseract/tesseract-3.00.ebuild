# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="An OCR Engine that was developed at HP and now at Google"
HOMEPAGE="http://code.google.com/p/tesseract-ocr/"
IUSE="tiff examples doc"
LANGS="zh_trad zh_simp in sv ro sl sr tl tr hu fi it nl no ja vi es uk fr sk ko el ru pt bg lv lt pl de de_frak da da_frak cs ca en"
for lang in ${LANGS}; do
	IUSE+=" linguas_${lang}"
done

SRC_URI="http://tesseract-ocr.googlecode.com/files/${P}.tar.gz
linguas_zh_trad? ( http://tesseract-ocr.googlecode.com/files/chi_tra.traineddata.gz )
linguas_zh_simp? ( http://tesseract-ocr.googlecode.com/files/chi_sim.traineddata.gz )
linguas_in? ( http://tesseract-ocr.googlecode.com/files/ind.traineddata.gz )
linguas_sv? ( http://tesseract-ocr.googlecode.com/files/swe.traineddata.gz )
linguas_ro? ( http://tesseract-ocr.googlecode.com/files/ron.traineddata.gz )
linguas_sl? ( http://tesseract-ocr.googlecode.com/files/slv.traineddata.gz )
linguas_sr? ( http://tesseract-ocr.googlecode.com/files/srp.traineddata.gz )
linguas_tl? ( http://tesseract-ocr.googlecode.com/files/tgl.traineddata.gz )
linguas_tr? ( http://tesseract-ocr.googlecode.com/files/tur.traineddata.gz )
linguas_hu? ( http://tesseract-ocr.googlecode.com/files/hun.traineddata.gz )
linguas_fi? ( http://tesseract-ocr.googlecode.com/files/fin.traineddata.gz )
linguas_it? ( http://tesseract-ocr.googlecode.com/files/ita.traineddata.gz )
linguas_nl? ( http://tesseract-ocr.googlecode.com/files/nld.traineddata.gz )
linguas_no? ( http://tesseract-ocr.googlecode.com/files/nor.traineddata.gz )
linguas_ja? ( http://tesseract-ocr.googlecode.com/files/jpn.traineddata.gz )
linguas_vi? ( http://tesseract-ocr.googlecode.com/files/vie.traineddata.gz )
linguas_es? ( http://tesseract-ocr.googlecode.com/files/spa.traineddata.gz )
linguas_uk? ( http://tesseract-ocr.googlecode.com/files/ukr.traineddata.gz )
linguas_fr? ( http://tesseract-ocr.googlecode.com/files/fra.traineddata.gz )
linguas_sk? ( http://tesseract-ocr.googlecode.com/files/slk.traineddata.gz )
linguas_ko? ( http://tesseract-ocr.googlecode.com/files/kor.traineddata.gz )
linguas_el? ( http://tesseract-ocr.googlecode.com/files/ell.traineddata.gz )
linguas_ru? ( http://tesseract-ocr.googlecode.com/files/rus.traineddata.gz )
linguas_pt? ( http://tesseract-ocr.googlecode.com/files/por.traineddata.gz )
linguas_bg? ( http://tesseract-ocr.googlecode.com/files/bul.traineddata.gz )
linguas_lv? ( http://tesseract-ocr.googlecode.com/files/lav.traineddata.gz )
linguas_lt? ( http://tesseract-ocr.googlecode.com/files/lit.traineddata.gz )
linguas_pl? ( http://tesseract-ocr.googlecode.com/files/pol.traineddata.gz )
linguas_de? ( http://tesseract-ocr.googlecode.com/files/deu.traineddata.gz )
linguas_de_frak? ( http://tesseract-ocr.googlecode.com/files/deu-frak.traineddata.gz )
linguas_da? ( http://tesseract-ocr.googlecode.com/files/dan-frak.traineddata.gz )
linguas_da_frak? ( http://tesseract-ocr.googlecode.com/files/dan.traineddata.gz )
linguas_cs? ( http://tesseract-ocr.googlecode.com/files/ces.traineddata.gz )
linguas_ca? ( http://tesseract-ocr.googlecode.com/files/cat.traineddata.gz )
linguas_en? ( http://tesseract-ocr.googlecode.com/files/eng.traineddata.gz )"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 x86"

DEPEND="tiff? ( media-libs/tiff )"
RDEPEND="${DEPEND}"
pkg_pretend() {
	if ! use linguas_zh_trad && ! use linguas_zh_simp && ! use linguas_in && ! use linguas_sv && ! use linguas_ro && \
	! use linguas_sl && ! use linguas_sr && ! use linguas_tl && ! use linguas_tr && ! use linguas_hu && \
	! use linguas_fi && ! use linguas_it && ! use linguas_nl && ! use linguas_no && ! use linguas_ja && \
	! use linguas_vi && ! use linguas_es && ! use linguas_uk && ! use linguas_fr && ! use linguas_sk && \
	! use linguas_ko && ! use linguas_el && ! use linguas_ru && ! use linguas_pt && ! use linguas_bg && \
	! use linguas_lv && ! use linguas_lt && ! use linguas_pl && ! use linguas_de && ! use linguas_de_frak && \
	! use linguas_da && ! use linguas_da_frak && ! use linguas_cs && ! use linguas_ca && ! use linguas_en ; then
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
