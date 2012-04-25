# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="AMD Accelerated Parallel Processing (APP) SDK (formerly ATI Stream)"
HOMEPAGE="http://developer.amd.com/sdks/amdappsdk/pages/default.aspx"

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
LICENSE="AMD GPL-1 as-is"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="examples profiler doc +eselect mesa"

# FIXME: Make sure dependency on ati-drivers is correct.
RDEPEND="app-admin/eselect-opengl
        sys-devel/llvm
        sys-devel/gcc
        media-libs/mesa
        media-libs/freeglut
        || ( dev-util/opencl-headers dev-util/nvidia-cuda-toolkit >=x11-drivers/ati-drivers-11.12[opencl] )
        examples? ( media-libs/glew )
        eselect? ( app-admin/eselect-opencl )"
DEPEND="${RDEPEND}
        dev-lang/perl
        dev-util/patchelf
        !<dev-util/amdstream-2.6"

RESTRICT="mirror strip"
FEATURES="multilib-strict"

if   [[ "${ARCH}" == "x86" ]]; then
    S="${WORKDIR}/${_ARCHIVE_UNPACKED_X86/.tgz/}"
elif [[ "${ARCH}" == "amd64" ]]; then
    S="${WORKDIR}/${_ARCHIVE_UNPACKED_AMD64/.tgz/}"
fi

#_installdir=/opt/amdstream
#_installdir=/usr/share/amdstream
#_installdir=/opt/AMDAPP
#_installdir=/opt/amd-app-sdk
_installdir=/usr/lib/amd

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
    # See https://aur.archlinux.org/packages.php?ID=21933
    epatch "${FILESDIR}/01-implicit-linking.patch"
    epatch "${FILESDIR}/02-readlink-include.patch"
}


src_compile() {
    # FIXME: Make sure examples are all compiled and installed.
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

    # Install clinfo
    dobin bin/${_arch}/clinfo

    dodir /usr/portage/licenses/
    cat docs/opencl/LICENSES > ${D}/usr/portage/licenses/${P}
    cat LICENSE-llvm.txt > ${D}/usr/portage/licenses/${P}-llvm
    cat LICENSE-mingw.txt > ${D}/usr/portage/licenses/${P}-mingw

    # Install include files
    # CAL and OpenVideo can go in /usr/include
    insinto /usr/include
    doins -r include/CAL include/OpenVideo
    # AMD APP includes OpenCL and OpenGL includes. Don't conflict with other packages.
    if use eselect; then
        insinto ${_installdir}/include
#     else
#         # FIXME: Is that valid?
#         dosym /usr/lib/libOpenCL.so.1 /usr/lib/libOpenCL.so
#         use multilib && dosym /usr/lib32/libOpenCL.so.1 /usr/lib32/libOpenCL.so
    fi
    doins -r include/CL
    doins -r include/GL

    # Include lib files
    # libaticalc.so and libaticalrt.so
    dolib.so lib/*.so
    # Architecture dependant
    # 32 bits
    # FIXME: On pure x86, should /usr/lib32 be used or /usr/lib?
    insinto /usr/lib32
    insopts -m0755
    doins lib/x86/{libamdocl32.so,libSlotMaximizerAg.so,libSlotMaximizerBe.so}
    insinto ${_installdir}/lib32
    doins lib/x86/{libGLEW.so,libglut.so}
    # libOpenCL.so
    insinto /usr/lib32/OpenCL/vendors/amd
    doins lib/x86/libOpenCL.so.1
    ln -s libOpenCL.so.1 ${D}/usr/lib32/OpenCL/vendors/amd/libOpenCL.so
    # 64 bits
    if use amd64; then
        insinto /usr/lib64
        doins lib/x86_64/{libamdocl64.so,libSlotMaximizerAg.so,libSlotMaximizerBe.so}
        insinto ${_installdir}/lib64
        doins lib/x86_64/{libGLEW.so,libglut.so}
        # libOpenCL.so
        insinto /usr/lib64/OpenCL/vendors/amd
        doins lib/x86_64/libOpenCL.so.1
        ln -s libOpenCL.so.1 ${D}/usr/lib64/OpenCL/vendors/amd/libOpenCL.so
    fi

    # Register ICD
    # http://www.khronos.org/registry/cl/extensions/khr/cl_khr_icd.txt
    insinto /etc/OpenCL/vendors/
    doins ../etc/OpenCL/vendors/*

    # Install examples
    if use examples; then
        insinto ${_installdir}/examples
        doins -r samples
        doins -r make
        doins Makefile
    fi

    if use doc; then
        for f in docs/opencl/*; do
            dodoc $f
        done
    fi

    # Create env file
    echo "ATISTREAMSDKROOT=${_installdir}" > 99${PN}
    doenvd 99${PN}

    echo "${_installdir}/$(get_libdir)" > ${D}/etc/ld.so.conf.d/99amdapp.conf

    # Install profiler
    if use profiler; then
        _PROF_P=`\ls tools`
        _PROF_PV=${_PROF_P/*-/}
        _PROF_PN=${_PROF_P/-*/}
        cat tools/${_PROF_P}/License.txt > ${D}/usr/portage/licenses/${_PROF_P} || die "Can't copy CLPerfMarker's license."

        dobin tools/${_PROF_P}/${_arch}/sprofile
        dolib tools/${_PROF_P}/${_arch}/*.so

        # CLPerfMarker
        # FIXME: there is bin/x86/libCLPerfMarker32.so and x86_64/libCLPerfMarker.so...
        dolib tools/${_PROF_P}/CLPerfMarker/bin/${_arch}/*.so
        insinto /usr/include
        doins tools/${_PROF_P}/CLPerfMarker/include/*

        if use doc; then
            docinto CLPerfMarker
            dodoc tools/${_PROF_P}/CLPerfMarker/doc/*
#             cp -r tools/${_PROF_P}/html   ${D}/usr/share/doc/${P}/CLPerfMarker  || die "Can't copy CLPerfMarker's doc folder."
#             cp -r tools/${_PROF_P}/jqPlot ${D}/usr/share/doc/${P}/              || die "Can't copy CLPerfMarker's jqPlot folder."
#             newdoc tools/${_PROF_P}/html CLPerfMarker
            dodoc -r tools/${_PROF_P}/jqPlot
            dodoc -r tools/${_PROF_P}/html
        fi
    fi

    # Prevent revdep_rebuild from trying to rebuild these
    dodir /etc/revdep-rebuild/
    # If installed in /usr/lib but "lib" is a link to "lib64", revdep_rebuild will not see that.
    # Manually change this.
    _id=${_installdir/lib/`get_libdir`}
    echo "SEARCH_DIRS_MASK=\"${_id} /usr/bin/clinfo  /usr/`get_libdir`/libCLProfileAgent.so /usr/`get_libdir`/libCLTraceAgent.so /usr/`get_libdir`/libGPUPerfAPICL.so\"" > "${D}"/etc/revdep-rebuild/10-${PN}

    # Fix libamdocl64.so's and libamdocl64.so's RPATH to point to MESA
    # This should fix a conflict when nvidia drivers provide libGL.so.
    if use mesa; then
        for libdir in "32" "64"; do
            patchelf --set-rpath /usr/lib${libdir}/opengl/xorg-x11/lib ${D}/usr/lib${libdir}/libamdocl${libdir}.so
        done
    fi
}
