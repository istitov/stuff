# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Author: vapier@gentoo.org
# Modified: barbieri@profusion.mobi
# Modified: NightNord@gmail.com
# Modified: gentoo.sera@bluewin.ch
# Modified: mike@zentific.com

# @ECLASS: efl.eclass
# @MAINTAINER:
# barbieri@profusion.mobi
# mike@zentific.com
# @BLURB: Provides common code for EFL package based ebuilds.
# @DESCRIPTION:
# Exports ebuild phase functions: src_unpack src_prepare src_configure
#   src_compile src_install src_test
#
# Reqires EAPI 2 or later.

case "${EAPI}" in
	2|3|4|5|6) ;;
	*) die "Unknown EAPI for efl eclass";;
esac

inherit eutils libtool flag-o-matic

# @ECLASS_VARIABLE: E_CYTHON
# @DESCRIPTION:
# if defined, the package is Cython bindings (implies E_PYTHON)

# Python support:
# @ECLASS_VARIABLE: E_PYTHON
# @DESCRIPTION:
# if defined, the package is Python/distutils
: ${E_PYTHON:=${E_CYTHON}}

# @ECLASS_VARIABLE: E_PKG_IUSE
# @DESCRIPTION:
# Use EFL_PKG_IUSE instead of IUSE for doc, examples, nls and test so that the
# eclass can automagically add the needed dependencies and or perform the
# required actions.
IUSE="${E_PKG_IUSE}"

# @ECLASS_VARIABLE: E_LIVE_SERVER_DEFAULT_SVN
# @DESCRIPTION:
# Default svn repository to use.
E_LIVE_SERVER_DEFAULT_SVN="http://svn.enlightenment.org/svn/e/trunk"

# @ECLASS_VARIABLE: E_EXTERNAL
# @DESCRIPTION:
# If defined, efl.eclass will not automatically inherit subversion and do any
# magic for it
: ${E_EXTERNAL:=}

# @ECLASS_VARIABLE: E_EXTERNAL
# @DESCRIPTION:
# If defined, efl.eclass will not automatically inherit subversion and do any
# magic for it
: ${E_GIT_PROJECT:=}

# @ECLASS_VARIABLE: E_LIVE_OFFLINE
# @DESCRIPTION:
# Use ESCM_OFFLINE="yes" only for enlightenment packages. Usefull if you want to
# have manual control over subversion revisions
: ${E_LIVE_OFFLINE:=}

# @ECLASS_VARIABLE: ESVN_URI_APPEND
# @DESCRIPTION:
# This is addition to final default svn repo path, namely package name
: ${ESVN_URI_APPEND:=${PN}}

# @ECLASS_VARIABLE: ESVN_SUB_PROJECT
# @DESCRIPTION:
# Sub-group into svn.enlightenment.org repository trunk
: ${ESVN_SUB_PROJECT:=}

# @ECLASS_VARIABLE: EFL_GIT_BASE_PATH
# @DESCRIPTION:
# Initial part of any official git repository url.
# You may respecify it to use local mirror instead of official git server
# Do NOT end it with slash '/'
: ${EFL_GIT_BASE_PATH:="https://git.enlightenment.org"}

# @ECLASS_VARIABLE: EFL_GIT_REPO_NAME
# @DESCRIPTION:
# Final part of git url, name of the repository. Default: ${PN}
: ${EFL_GIT_REPO_NAME:=${PN}}

# @ECLASS_VARIABLE: EFL_GIT_REPO_CATEGORY
# @DESCRIPTION:
# Middle part of git url, category of the repository. Default: None
: ${EFL_GIT_REPO_CATEGORY:=}

E_STATE="release"
if [[ ${PV/9999} != ${PV} ]] ; then
	E_STATE="live"

	# TODO live is not a permitted token according to pms.
	# Switch to the mechanism to denote live packages once decided upon and
	# available.
	PROPERTIES="live"

	: ${WANT_AUTOTOOLS:=yes}

	if [[ -z "${E_EXTERNAL}" ]]; then
		if [[ -z "${EFL_USE_GIT}" ]]; then
			[[ -n ${E_LIVE_OFFLINE} ]] && ESCM_OFFLINE="yes"

			E_LIVE_SERVER=${E_LIVE_SERVER_DEFAULT_SVN}
			ESVN_PROJECT="enlightenment/${ESVN_SUB_PROJECT}"
			ESVN_REPO_URI="${E_LIVE_SERVER}/${ESVN_SUB_PROJECT}/${ESVN_URI_APPEND}"

			S="${WORKDIR}/${ESVN_URI_APPEND}"

			inherit subversion
		else
			EGIT_REPO_URI="${EFL_GIT_BASE_PATH}/${EFL_GIT_REPO_CATEGORY}"
			EGIT_REPO_URI="${EGIT_REPO_URI}/${EFL_GIT_REPO_NAME}.git"
			EGIT_CLONE_TYPE=shallow
			inherit git-r3
		fi
	fi
fi

if [[ -n "${E_PYTHON}" ]]; then
	PYTHON_COMPAT=( python{2_7,3_{4,5}} )
	inherit python-r1
fi


if [[ ${WANT_AUTOTOOLS} == "yes" ]] ; then
	: ${WANT_AUTOCONF:=${E_WANT_AUTOCONF:-latest}}
	: ${WANT_AUTOMAKE:=${E_WANT_AUTOMAKE:-latest}}

	inherit autotools
fi

HOMEPAGE="http://www.enlightenment.org/"

LICENSE="BSD"
SLOT="0"

DEPEND="${DEPEND} virtual/pkgconfig"

if has nls ${IUSE}; then
	DEPEND="${DEPEND} nls? ( sys-devel/gettext )"
fi

if has doc ${IUSE}; then
	DEPEND="${DEPEND} doc? ( app-doc/doxygen )"
fi

if [[ -z "${E_PYTHON}" ]] && has test ${IUSE}; then
	DEPEND="${DEPEND} test? ( dev-libs/check )"
fi

if [[ ! -z "${E_CYTHON}" ]]; then
	DEPEND="${DEPEND} >=dev-python/cython-0.12.1"
fi

# @FUNCTION: efl_warning_msg
# @USAGE:
# @DESCRIPTION:
# print server used and what to do if things go haywire
efl_warning_msg() {
	if [[ -n ${E_LIVE_SERVER} ]] ; then
		einfo "Using user server for live sources: ${E_LIVE_SERVER}"
	fi

	if [[ ${E_STATE} == "live" ]] ; then
		eerror "This is a LIVE SOURCES ebuild."
		eerror "That means there are NO promises it will work."
	fi
}

# @FUNCTION: efl_die
# @USAGE:
# @DESCRIPTION:
# calls efl_warning_msg and then die
efl_die() {
	efl_warning_msg
	die "$@"$'\n'"!!! SEND BUG REPORTS TO enlightenment@gentoo.org NOT THE E TEAM"
}

# @FUNCTION: efl_src_test
# @USAGE:
# @DESCRIPTION:
# calls emake check on non python packages with test in EFL_PKG_IUSE
efl_src_test() {
	emake -j1 check || die "Make check failed. see above for details"
}

# @FUNCTION: efl_src_unpack
# @USAGE:
# @DESCRIPTION:
# calls <scm>_src_unpack for live packages otherwise default_src_unpack
efl_src_unpack() {
	if [[ "${E_STATE}" == "live" ]]; then
		if [[ -z "${EFL_USE_GIT}" ]]; then
			subversion_src_unpack
		else
			git-r3_src_unpack
		fi
	else
		default_src_unpack
	fi
}

# @FUNCTION: efl_src_prepare
# @USAGE:
# @DESCRIPTION:
# Runs the autotools stuff.
efl_src_prepare() {
	if [[ ${EAPI} -ge 6 ]]; then
		eapply_user
	else
		epatch_user
	fi

	[[ -s gendoc ]] && chmod a+rx gendoc

	if [[ -e configure.ac || -e configure.in ]] && [[ "${WANT_AUTOTOOLS}" == "yes" ]]; then
		export SVN_REPO_PATH="${ESVN_WC_PATH}"

		if has nls ${IUSE} && use nls; then
			eautopoint -f
		fi

		[[ -f README.in ]] && touch README

		eautoreconf
	fi

	elibtoolize
}

# @FUNCTION: efl_src_configure
# @USAGE:
# @DESCRIPTION:
# efl's default src_configure
efl_src_configure() {
	if [[ -x ${ECONF_SOURCE:-.}/configure ]]; then
		has nls ${IUSE} && MY_ECONF+=" $(use_enable nls)"
		has doc ${IUSE} && MY_ECONF+=" $(use_enable doc)"

		if has static-libs ${IUSE}; then
			MY_ECONF+=" $(use_enable static-libs static)"
		else
			MY_ECONF+=" --disable-static"
		fi

		econf ${MY_ECONF} || efl_die "configure failed"
fi
}

# @FUNCTION: efl_src_compile
# @USAGE:
# @DESCRIPTION:
# efl's default src_compile
efl_src_compile() {
	emake || efl_die "emake failed"

	if has doc ${IUSE} && use doc; then
		if [[ -x ./gendoc ]]; then
			./gendoc || efl_die "gendoc failed"
		else
			emake doc || efl_die "emake doc failed"
		fi
	fi
}

# @FUNCTION: efl_src_install
# @USAGE:
# @DESCRIPTION:
# efl's default src_install
efl_src_install() {
	emake install DESTDIR="${D}" || efl_die

	find "${D}" -name '*.la' -delete

	local doc
	for doc in AUTHORS ChangeLog NEWS README TODO ${EDOCS}; do
		[[ -f ${doc} ]] && dodoc ${doc}
	done

	if has examples ${IUSE} && use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi

	if has doc ${IUSE} && use doc && [[ -d doc ]]; then
		if [[ -d doc/html ]]; then
			dohtml -r doc/html/*
		else
			dohtml -r doc/*
		fi
	fi

	# Needed only for subversion-1.6. Remove as soon as only 1.7 will remain
	find "${D}" -name .svn -type d -exec rm -rf '{}' \; 2>/dev/null
}

EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install src_test
