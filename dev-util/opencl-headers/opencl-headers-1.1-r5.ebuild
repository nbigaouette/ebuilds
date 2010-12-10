# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/valgrind/valgrind-3.6.0.ebuild,v 1.1 2010/11/10 01:40:41 blueness Exp $

# http://aur.archlinux.org/packages/libatical/libatical/PKGBUILD

EAPI=3

DESCRIPTION="OpenCL headers from Khronos.org"
HOMEPAGE="http://www.khronos.org/"

SRC_URI="http://www.khronos.org/registry/cl/api/${PV}/opencl.h
         http://www.khronos.org/registry/cl/api/${PV}/cl_platform.h
         http://www.khronos.org/registry/cl/api/${PV}/cl.h
         http://www.khronos.org/registry/cl/api/${PV}/cl_ext.h
         http://www.khronos.org/registry/cl/api/${PV}/cl_gl.h
         http://www.khronos.org/registry/cl/api/${PV}/cl_gl_ext.h
         http://www.khronos.org/registry/cl/api/${PV}/cl.hpp"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=""
DEPEND="${RDEPEND}"

RESTRICT="mirror"

src_install() {
    mkdir -p ${D}/usr/include/CL
    #install -m755 ${_libaticaldir}/{libaticalcl.so,libaticaldd.so,libaticalrt.so} ${D}/usr/lib/
    cd ${DISTDIR}
    for f in *; do
        install -m644 $f ${D}/usr/include/CL
    done
}
