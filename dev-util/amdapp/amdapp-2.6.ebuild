# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="AMD Accelerated Parallel Processing (APP) SDK (formerly ATI Stream)"
HOMEPAGE="http://developer.amd.com/sdks/amdappsdk/pages/default.aspx"

_OpenCL_ver_major=1
_OpenCL_ver_minor=2

_ARCHIVE_NAME="AMD-APP-SDK"
_ARCHIVE_DONWLOAD_BASE="${_ARCHIVE_NAME}-v${PV}-lnxARCHBASE.tgz"
_ARCHIVE_UNPACKED_BASE="${_ARCHIVE_NAME}-v${PV}-RC3-lnxARCHBASE.tgz"
_ARCHIVE_DONWLOAD_X86=${_ARCHIVE_DONWLOAD_BASE/ARCHBASE/32}
_ARCHIVE_UNPACKED_X86=${_ARCHIVE_UNPACKED_BASE/ARCHBASE/32}
_ARCHIVE_DONWLOAD_AMD64=${_ARCHIVE_DONWLOAD_BASE/ARCHBASE/64}
_ARCHIVE_UNPACKED_AMD64=${_ARCHIVE_UNPACKED_BASE/ARCHBASE/64}

SRC_URI="
    x86?   ( http://developer.amd.com/Downloads/${_ARCHIVE_DONWLOAD_X86}   )
    amd64? ( http://developer.amd.com/Downloads/${_ARCHIVE_DONWLOAD_AMD64} )
"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="examples profiler"

RDEPEND="app-admin/eselect-opengl
        sys-devel/llvm
        sys-devel/gcc
        media-libs/mesa
        || ( dev-util/opencl-headers dev-util/nvidia-cuda-toolkit )
        media-libs/glew
        media-libs/freeglut"
DEPEND="${RDEPEND}
        dev-lang/perl
        !<dev-util/amdstream-2.6"

RESTRICT="mirror strip"

if   [[ "${ARCH}" == "x86" ]]; then
    S="${WORKDIR}/${_ARCHIVE_UNPACKED_X86/.tgz/}"
elif [[ "${ARCH}" == "amd64" ]]; then
    S="${WORKDIR}/${_ARCHIVE_UNPACKED_AMD64/.tgz/}"
fi

src_unpack() {
    default_src_unpack
    if use x86; then
        unpack ./${_ARCHIVE_UNPACKED_X86}
    elif use amd64; then
        unpack ./${_ARCHIVE_UNPACKED_AMD64}
    else
        die "Architecture not supported or not detected correctly!"
    fi

    unpack ./icd-registration.tgz
}

src_prepare() {
    epatch "${FILESDIR}/01-implicit-linking.patch"
}


src_compile() {
    if use examples; then
        emake -j1 || die "Make failed!"
    fi
}

src_install() {

    if use x86; then
        _arch="x86"
        _other_arch="x86_64"
    elif use amd64; then
        _arch="x86_64"
        _other_arch="x86"
    else
        die "Architecture not supported or not detected correctly!"
    fi

    #_installdir=/opt/amdstream
    #_installdir=/usr/share/amdstream
    #_installdir=/opt/AMDAPP
    _installdir=/usr/lib/amd

    # Install clinfo
    dobin bin/${_arch}/clinfo

    dodir /usr/portage/licenses/
    cat docs/opencl/LICENSES > ${D}/usr/portage/licenses/${P}
    cat LICENSE-llvm.txt > ${D}/usr/portage/licenses/${P}-llvm
    cat LICENSE-mingw.txt > ${D}/usr/portage/licenses/${P}-mingw

    # Install docs
    for f in docs/opencl/*; do
        dodoc $f
    done

    # Install include files
    for d in include/*; do
        insinto ${_installdir}/usr/${d}
        for f in ${d}/*; do
            doins $f
        done
    done

    # Include lib files
    insinto ${_installdir}/usr/lib
    doins lib/*.so
    #dolib lib/*.so
    insinto ${_installdir}/usr/lib32
    doins lib/x86/*
    if use amd64; then
        insinto ${_installdir}/usr/lib64
        doins lib/x86_64/*
    fi

    # Install profiler
    if use profiler; then
        _PROF_P=`ls tools`
        _PROF_PV=${_PROF_P/*-/}
        _PROF_PN=${_PROF_P/-*/}
        cat tools/${_PROF_P}/License.txt > ${D}/usr/portage/licenses/${_PROF_P} || die "Can't copy CLPerfMarker's license."

        dobin tools/${_PROF_P}/${_arch}/sprofile
        dolib tools/${_PROF_P}/${_arch}/*.so

        # CLPerfMarker
        dolib tools/${_PROF_P}/CLPerfMarker/bin/${_arch}/*.so
        insinto /usr/include
        doins tools/${_PROF_P}/CLPerfMarker/include/*
        dodoc tools/${_PROF_P}/CLPerfMarker/doc/*
        cp -r tools/${_PROF_P}/html   ${D}/usr/share/doc/${P}/CLPerfMarker  || die "Can't copy CLPerfMarker's doc folder."
        cp -r tools/${_PROF_P}/jqPlot ${D}/usr/share/doc/${P}/              || die "Can't copy CLPerfMarker's jqPlot folder."
    fi

    # Register ICD
    insinto /etc/OpenCL/vendors/
    doins ../etc/OpenCL/vendors/*
    # The icd file just contains the filename. Set it to absolute path
    for _arch in 32 64; do
        icd_file="${D}/etc/OpenCL/vendors/amdocl${_arch}.icd"
        icd_file_content=`cat ${icd_file}`
        echo "${_installdir}/usr/lib${_arch}/`basename ${icd_file_content}`" > ${icd_file}
    done


#     #Install SDK
#     mkdir -p ${D}${_installdir}
#     cp -r {glut_notice.txt,docs,include,samples} ${D}${_installdir}/
#     mkdir -p ${D}${_installdir}/{bin/${_arch},lib,samples}
#     cp -r ./bin/${_arch}/clinfo ${D}${_installdir}/bin/${_arch}/clinfo
#     cp -r ./lib/${_arch} ${D}${_installdir}/lib/
#     rm -rf ${D}${_installdir}/samples/opencl/bin/${_other_arch}
#     rm -rf ${D}${_installdir}/samples/cal/bin/${_other_arch}
# 
#     #Register ICD
#     #tar -zxvf icd-registration.tgz > /dev/null
#     #cp -r etc ${D}/
#     mkdir -p ${D}/etc/OpenCL/vendors/
#     echo "${_installdir}/lib/x86_64/libamdocl64.so" > ${D}/etc/OpenCL/vendors/amdocl64.icd
#     # FIXME: do the same for 32 bit
# 
#     #Install includes
#     mkdir -p ${D}/usr/include/{CAL,OVDecode}
#     install -m644 ./include/CAL/{calcl.h,cal_ext.h,cal_ext_counter.h,cal.h} ${D}/usr/include/CAL/
#     #install -m644 ./include/CL/{cl_agent_amd.h,cl_icd.h} $pkgdir/usr/include/CL/
#     install -m644 ./include/OVDecode/{OVDecode.h,OVDecodeTypes.h} ${D}/usr/include/OVDecode
# 
#     ##Add stream libs to shared library path
#     #mkdir -p ${D}/etc/ld.so.conf.d
#     #cd ${D}/etc/ld.so.conf.d
#     #echo ${_installdir}/lib/${_arch} > amdstream.conf
#     #echo ${_installdir}/lib/gpu >> amdstream.conf
# 
#     #Symlink libs (instead)
#     mkdir -p ${D}/usr/lib/amd/
#     ln -s ${_installdir}/lib/${_arch}/libOpenCL.so ${D}/usr/lib/amd/libOpenCL.so
#     ln -s libOpenCL.so ${D}/usr/lib/amd/libOpenCL.so.$_OpenCL_ver_major.$_OpenCL_ver_minor
#     ln -s libOpenCL.so ${D}/usr/lib/amd/libOpenCL.so.$_OpenCL_ver_major
#     #ln -s ${_installdir}/lib/${_arch}/libOpenCL.so ${D}/usr/lib/libOpenCL.so.$_OpenCL_ver_major.$_OpenCL_ver_minor
#     #ln -s ${_installdir}/lib/libOpenCL.so.$_OpenCL_ver_major.$_OpenCL_ver_minor ${D}/usr/lib/libOpenCL.so.$_OpenCL_ver_major
#     #ln -s ${_installdir}/lib/libOpenCL.so.$_OpenCL_ver_major.$_OpenCL_ver_minor ${D}/usr/lib/libOpenCL.so
#     ln -s ${_installdir}/lib/${_arch}/libamdocl64.so ${D}/usr/lib/amd/libamdocl64.so
# 
#     #Symlink binaries
#     mkdir -p ${D}/usr/bin
#     ln -s ${_installdir}/bin/${_arch}/clinfo ${D}/usr/bin/clinfo
# 
#     #Env vars
#     mkdir -p ${D}/etc/profile.d
#     cd ${D}/etc/profile.d
#     echo "#!/bin/sh" > amdstream.sh
#     echo "export AMDAPPSDKROOT=${_installdir}" >> amdstream.sh
#     echo "export AMDAPPSDKSAMPLESROOT=${_installdir}" >> amdstream.sh
# 
#     #Fix modes
#     find ${D}${_installdir}/ -type f -exec chmod 644 {} \;
#     chmod 755 ${D}${_installdir}/bin/${_arch}/clinfo
#     chmod 755 ${D}${_installdir}/lib/${_arch}/*.so
#     find ${D}${_installdir}/samples/ -type f -not -name "*.*" -path "*/${_arch}/*" -exec chmod 755 {} \;
# 
#     ##More docs and export
#     #mkdir -p ${D}/etc/env.d
#     #echo "AMDSTREAMSDKROOT=${_installdir}/" >> ${D}/etc/env.d/99amdstream
#     #echo "AMDSTREAMSDKSAMPLEROOT=${_installdir}/" >> ${D}/etc/env.d/99amdstream
#     #echo "LDPATH=${_installdir}/lib/${_arch}" >> ${D}/etc/env.d/99amdstream
#     #echo "PATH=${_installdir}/bin/${_arch}" >> ${D}/etc/env.d/99amdstream
#     #echo "LIBRARY_PATH=${_installdir}/lib/x86_64" >> ${D}/etc/env.d/99amdstream
}
