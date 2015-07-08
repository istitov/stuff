# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-opencl/eselect-opencl-1.1.0-r1.ebuild,v 1.5 2012/05/16 14:43:18 aballier Exp $

EAPI=5
CL_ABI=1.2

inherit multilib

DESCRIPTION="Utility to change the OpenCL implementation being used"
HOMEPAGE="http://www.khronos.org/registry/cl/"

# Source:
# http://www.khronos.org/registry/cl/api/${CL_ABI}/opencl.h
# http://www.khronos.org/registry/cl/api/${CL_ABI}/cl_platform.h
# http://www.khronos.org/registry/cl/api/${CL_ABI}/cl.h
# http://www.khronos.org/registry/cl/api/${CL_ABI}/cl_ext.h
# http://www.khronos.org/registry/cl/api/${CL_ABI}/cl_gl.h
# http://www.khronos.org/registry/cl/api/${CL_ABI}/cl_gl_ext.h
# http://www.khronos.org/registry/cl/api/${CL_ABI}/cl.hpp

MIRROR="http://www.khronos.org/registry/cl/api/${CL_ABI}/"
SRC_URI="${MIRROR}/opencl.h
	${MIRROR}/cl_platform.h
	${MIRROR}/cl.h
	${MIRROR}/cl_ext.h
	${MIRROR}/cl_gl.h
	${MIRROR}/cl_egl.h
	${MIRROR}/cl_gl_ext.h
	${MIRROR}/cl.hpp
	http://dev.gentoo.org/~xarthisius/distfiles/${P}-r1.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 ~amd64-fbsd ~x86-fbsd"
IUSE=""

DEPEND="app-arch/xz-utils"
RDEPEND=">=app-admin/eselect-1.2.4"

pkg_postinst() {
	local impl="$(eselect opencl show)"
	if [[ -n "${impl}"  && "${impl}" != '(none)' ]] ; then
		eselect opencl set "${impl}"
	fi
}

src_install() {
	insinto /usr/share/eselect/modules
	doins opencl.eselect
	#doman opencl.eselect.5

	local headers=( opencl.h cl_platform.h cl.h cl_egl.h cl_ext.h cl_gl.h cl_gl_ext.h cl.hpp )
	insinto /usr/$(get_libdir)/OpenCL/global/include/CL
	doins "${DISTDIR}"/{*.h,*.hpp}
}
