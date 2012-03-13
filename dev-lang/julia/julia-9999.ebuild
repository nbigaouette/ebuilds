# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

EGIT_REPO_URI="git://github.com/JuliaLang/julia.git"

inherit git-2 eutils


DESCRIPTION="The Julia Language: a fresh approach to technical computing"
HOMEPAGE="http://julialang.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+builtin lighttpd"

RDEPEND="
    !builtin? (
        >=sys-devel/llvm-3.0
        sys-libs/readline
        virtual/blas
        virtual/lapack
        sci-libs/suitesparse
        sci-libs/arpack
        sci-libs/fftw
        dev-libs/gmp
        sys-libs/libunwind
        dev-libs/libpcre
    )
    lighttpd? ( www-servers/lighttpd )"
DEPEND="
    sys-devel/make
    dev-vcs/git
    dev-lang/perl
    sys-devel/m4
    ${RDEPEND}"

src_prepare() {
    # Use system packages instead of included ones
    if use !builtin; then
        sed \
            -e "s|USE_SYSTEM_LLVM=.*|USE_SYSTEM_LLVM=1|g" \
            -e "s|USE_SYSTEM_LIBUNWIND=.*|USE_SYSTEM_LIBUNWIND=1|g" \
            -e "s|USE_SYSTEM_READLINE=.*|USE_SYSTEM_READLINE=1|g" \
            -e "s|USE_SYSTEM_BLAS=.*|USE_SYSTEM_BLAS=1|g" \
            -e "s|USE_SYSTEM_LAPACK=.*|USE_SYSTEM_LAPACK=1|g" \
            -e "s|USE_SYSTEM_FFTW=.*|USE_SYSTEM_FFTW=1|g" \
            -e "s|USE_SYSTEM_GMP=.*|USE_SYSTEM_GMP=1|g" \
            -e "s|USE_SYSTEM_ARPACK=.*|USE_SYSTEM_ARPACK=1|g" \
            -e "s|USE_SYSTEM_SUITESPARSE=.*|USE_SYSTEM_SUITESPARSE=1|g" \
            -e "s|USE_SYSTEM_PCRE=.*|USE_SYSTEM_PCRE=1|g" \
            -i Make.inc || die "Can't sed."

        # https://github.com/JuliaLang/julia/issues/450
        mkdir -p ${WORKDIR}/${P}/external/root/lib || die "Can't creat external/root/lib folder."
        ln -s /$(get_libdir)/libpcre.so.0 ${WORKDIR}/${P}/external/root/lib/libpcre.so || die "Can't add symbolic link to pcre"

        # Folder /usr/include/suitesparse does not exists, everything should be in /usr/include
        sed -e "s|SUITESPARSE_INC = -I /usr/include/suitesparse|SUITESPARSE_INC =|g" -i external/Makefile
    fi
}

src_compile() {
    cd external || die "Could not enter 'external' directory!"

    # Create libsuitesparse.{so,a} from all sci-libs/suitesparse different libraries
    if use builtin; then
        LIBLAPACK=external/lapack-*/liblapack.a
        LIBBLAS=external/openblas-*/libopenblas.a
    else
        LIBLAPACK=-llapack
        LIBBLAS=-lblas
    fi
    gfortran -shared ${FFLAGS} \
            /usr/$(get_libdir)/libumfpack.so \
            /usr/$(get_libdir)/libcholmod.so \
            /usr/$(get_libdir)/libspqr.so \
            /usr/$(get_libdir)/libamd.so \
            /usr/$(get_libdir)/libamdf77.so \
            /usr/$(get_libdir)/libcamd.so \
            /usr/$(get_libdir)/libccolamd.so \
            /usr/$(get_libdir)/libcolamd.so \
            /usr/$(get_libdir)/libbtf.so \
            /usr/$(get_libdir)/libufconfig.so \
        ${LIBLAPACK} ${LIBBLAS} -lstdc++ -o ${WORKDIR}/${P}/external/root/lib/libsuitesparse.so

    cd ${S} || die "Can't cd into ${S}!"
    emake
}

src_install() {
    emake install DESTDIR=${D} PREFIX=/usr
    dosym ${D}/usr/share/julia/julia /usr/bin/julia
    dosym ${D}/usr/share/julia/julia-release-basic /usr/bin/julia-basic
    dosym ${D}/usr/share/julia/julia-release-webserver /usr/bin/julia-webserver

    # Delete libraries used for compilation
    rm -f ${D}/usr/share/julia/lib/libpcre.so
    #rm -f ${D}/usr/share/julia/lib/libsuitesparse.so # Until sci-libs/suitesparse creates the file, don't delete it.

    ln -s /$(get_libdir)/libpcre.so.0 ${D}/usr/share/julia/lib/libpcre.so || die "Can't add symbolic link to pcre"
}

src_test() {
    cd ${S}/test    || die "Can't cd into test directory"
    make            || die "Running tests failed"
}
