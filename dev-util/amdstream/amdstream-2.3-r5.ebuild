# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/valgrind/valgrind-3.6.0.ebuild,v 1.1 2010/11/10 01:40:41 blueness Exp $

# http://aur.archlinux.org/packages/libatical/libatical/PKGBUILD

EAPI=3

DESCRIPTION="AMD ATI Stream SDK, now wtih OpenCL support"
HOMEPAGE="http://developer.amd.com/gpu/ATIStreamSDK/Pages/default.aspx"

IUSE="catalyst"

if [[ "${ARCH}" == "amd64" ]]; then
    _arch="x86_64"
    _other_arch="x86"
    _bits="64"
elif [[ "${ARCH}" == "x86" ]]; then
    _arch="x86"
    _other_arch="x86_64"
    _bits="32"
fi

SRC_URI="http://download2-developer.amd.com/amd/Stream20GA/ati-stream-sdk-v${PV}-lnx${_bits}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"


RDEPEND=">=dev-util/libatical-10.11
        app-admin/eselect-opengl
        sys-devel/llvm
        sys-devel/gcc
        media-libs/mesa
        dev-util/opencl-headers
        !x11-drivers/nvidia-drivers
        x11-libs/libXext"
DEPEND="${RDEPEND}
        dev-lang/perl"

#RESTRICT="mirror strip"
RESTRICT="mirror"

src_compile() {
    cd "${WORKDIR}/ati-stream-sdk-v${PV}-lnx${_bits}"
    emake -j1 || die "Make failed!"
}

src_install() {

    cd "${WORKDIR}/ati-stream-sdk-v${PV}-lnx${_bits}"

    #Install SDK
    mkdir -p ${D}/opt/amdstream
    cp -r {glut_notice.txt,docs,include,samples} ${D}/opt/amdstream/
    mkdir -p ${D}/opt/amdstream/{bin/$_arch,lib,samples}
    cp -r ./bin/$_arch/clc ${D}/opt/amdstream/bin/$_arch/clc
    cp -r ./lib/$_arch ${D}/opt/amdstream/lib/
    cp -r ./lib/gpu ${D}/opt/amdstream/lib/
    rm -rf ${D}/opt/amdstream/samples/opencl/bin/$_other_arch
    rm -rf ${D}/opt/amdstream/samples/cal/bin/$_other_arch

    #Register ICD
    tar -zxvf icd-registration.tgz > /dev/null
    cp -r etc ${D}/

    #Insall includes
    mkdir -p ${D}/usr/include/CL
    install -m644 ./include/{calcl.h,cal_ext.h,cal_ext_counter.h,cal.h} ${D}/usr/include/
    install -m644 ./include/CL/{cl_agent_amd.h,cl_icd.h} ${D}/usr/include/CL/
    mkdir -p ${D}/usr/include/OVDecode
    install -m644 ./include/OVDecode/{OVDecode.h,OVDecodeTypes.h} ${D}/usr/include/OVDecode

    #Symlink binaries
    mkdir -p ${D}/usr/bin
    ln -s /opt/amdstream/bin/$_arch/clc ${D}/usr/bin/

    #Add stream libs to shared library path
    mkdir -p ${D}/etc/ld.so.conf.d
    cd ${D}/etc/ld.so.conf.d
    echo /opt/amdstream/lib/$_arch > amdstream.conf
    echo /opt/amdstream/lib/gpu >> amdstream.conf

    #More docs and export
    mkdir -p ${D}/etc/profile.d
    cd ${D}/etc/profile.d
    echo "#!/bin/sh" > amdstream.sh
    echo "export AMDSTREAMSDKROOT=/opt/amdstream/" >> amdstream.sh
    echo "export AMDSTREAMSDKSAMPLEROOT=/opt/amdstream/" >> amdstream.sh

    #Fix modes
    find ${D}/opt/amdstream/ -type f -exec chmod 644 {} \;
    chmod 755 ${D}/opt/amdstream/bin/$_arch/clc
    chmod 755 ${D}/opt/amdstream/lib/$_arch/*.so
    find ${D}/opt/amdstream/samples/ -type f -not -name "*.*" -path "*/$_arch/*" -exec chmod 755 {} \;
}