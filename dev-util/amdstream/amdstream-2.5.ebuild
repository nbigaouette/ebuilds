# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="AMD Accelerated Parallel Processing (APP) SDK (formerly ATI Stream)"
HOMEPAGE="http://developer.amd.com/sdks/amdappsdk/pages/default.aspx"

_OpenCL_ver_major=1
_OpenCL_ver_minor=1

if [[ "${ARCH}" == "amd64" ]]; then
    _arch="x86_64"
    _other_arch="x86"
    _bits="64"
elif [[ "${ARCH}" == "x86" ]]; then
    _arch="x86"
    _other_arch="x86_64"
    _bits="32"
fi

_ARCHIVE_NAME="AMD-APP-SDK"
_ARCHIVE_DONWLOAD="${_ARCHIVE_NAME}-v${PV}-lnx${_bits}.tgz"
_ARCHIVE_UNPACKED="${_ARCHIVE_NAME}-v${PV}-RC2-lnx${_bits}.tgz"

SRC_URI="http://developer.amd.com/Downloads/${_ARCHIVE_DONWLOAD}"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="app-admin/eselect-opengl
        sys-devel/llvm
        sys-devel/gcc
        media-libs/mesa
        || ( dev-util/opencl-headers dev-util/nvidia-cuda-toolkit )
        media-libs/glew
        media-libs/freeglut"
DEPEND="${RDEPEND}
        dev-lang/perl"

RESTRICT="mirror strip"

S="${WORKDIR}/${_ARCHIVE_UNPACKED/.tgz/}"

src_unpack() {
    default_src_unpack
    unpack ./${_ARCHIVE_UNPACKED}
}

src_compile() {
    emake -j1 || die "Make failed!"
}

src_install() {
    #_installdir=/opt/amdstream
    _installdir=/usr/share/amdstream

    #Install SDK
    mkdir -p ${D}${_installdir}
    cp -r {glut_notice.txt,docs,include,samples} ${D}${_installdir}/
    mkdir -p ${D}${_installdir}/{bin/${_arch},lib,samples}
    cp -r ./bin/${_arch}/clinfo ${D}${_installdir}/bin/${_arch}/clinfo
    cp -r ./lib/${_arch} ${D}${_installdir}/lib/
    rm -rf ${D}${_installdir}/samples/opencl/bin/${_other_arch}
    rm -rf ${D}${_installdir}/samples/cal/bin/${_other_arch}

    #Register ICD
    #tar -zxvf icd-registration.tgz > /dev/null
    #cp -r etc ${D}/
    mkdir -p ${D}/etc/OpenCL/vendors/
    echo "${_installdir}/lib/x86_64/libamdocl64.so" > ${D}/etc/OpenCL/vendors/amdocl64.icd
    # FIXME: do the same for 32 bit

    #Install includes
    mkdir -p ${D}/usr/include/{CAL,OVDecode}
    install -m644 ./include/CAL/{calcl.h,cal_ext.h,cal_ext_counter.h,cal.h} ${D}/usr/include/CAL/
    #install -m644 ./include/CL/{cl_agent_amd.h,cl_icd.h} $pkgdir/usr/include/CL/
    install -m644 ./include/OVDecode/{OVDecode.h,OVDecodeTypes.h} ${D}/usr/include/OVDecode

    ##Add stream libs to shared library path
    #mkdir -p ${D}/etc/ld.so.conf.d
    #cd ${D}/etc/ld.so.conf.d
    #echo ${_installdir}/lib/${_arch} > amdstream.conf
    #echo ${_installdir}/lib/gpu >> amdstream.conf

    #Symlink libs (instead)
    mkdir -p ${D}/usr/lib/amd/
    ln -s ${_installdir}/lib/${_arch}/libOpenCL.so ${D}/usr/lib/amd/libOpenCL.so
    ln -s libOpenCL.so ${D}/usr/lib/amd/libOpenCL.so.$_OpenCL_ver_major.$_OpenCL_ver_minor
    ln -s libOpenCL.so ${D}/usr/lib/amd/libOpenCL.so.$_OpenCL_ver_major
    #ln -s ${_installdir}/lib/${_arch}/libOpenCL.so ${D}/usr/lib/libOpenCL.so.$_OpenCL_ver_major.$_OpenCL_ver_minor
    #ln -s ${_installdir}/lib/libOpenCL.so.$_OpenCL_ver_major.$_OpenCL_ver_minor ${D}/usr/lib/libOpenCL.so.$_OpenCL_ver_major
    #ln -s ${_installdir}/lib/libOpenCL.so.$_OpenCL_ver_major.$_OpenCL_ver_minor ${D}/usr/lib/libOpenCL.so
    ln -s ${_installdir}/lib/${_arch}/libamdocl64.so ${D}/usr/lib/amd/libamdocl64.so

    #Symlink binaries
    mkdir -p ${D}/usr/bin
    ln -s ${_installdir}/bin/${_arch}/clinfo ${D}/usr/bin/clinfo

    #Env vars
    mkdir -p ${D}/etc/profile.d
    cd ${D}/etc/profile.d
    echo "#!/bin/sh" > amdstream.sh
    echo "export AMDAPPSDKROOT=${_installdir}" >> amdstream.sh
    echo "export AMDAPPSDKSAMPLESROOT=${_installdir}" >> amdstream.sh

    #Fix modes
    find ${D}${_installdir}/ -type f -exec chmod 644 {} \;
    chmod 755 ${D}${_installdir}/bin/${_arch}/clinfo
    chmod 755 ${D}${_installdir}/lib/${_arch}/*.so
    find ${D}${_installdir}/samples/ -type f -not -name "*.*" -path "*/${_arch}/*" -exec chmod 755 {} \;

    ##More docs and export
    #mkdir -p ${D}/etc/env.d
    #echo "AMDSTREAMSDKROOT=${_installdir}/" >> ${D}/etc/env.d/99amdstream
    #echo "AMDSTREAMSDKSAMPLEROOT=${_installdir}/" >> ${D}/etc/env.d/99amdstream
    #echo "LDPATH=${_installdir}/lib/${_arch}" >> ${D}/etc/env.d/99amdstream
    #echo "PATH=${_installdir}/bin/${_arch}" >> ${D}/etc/env.d/99amdstream
    #echo "LIBRARY_PATH=${_installdir}/lib/x86_64" >> ${D}/etc/env.d/99amdstream
}
