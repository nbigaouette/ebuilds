# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit subversion toolchain-funcs

DESCRIPTION="A general purpose messaging, notification and menuing program for X11."
HOMEPAGE="http://gotmor.googlepages.com/dzen"
SRC_URI=""
ESVN_REPO_URI="http://dzen.googlecode.com/svn/trunk/"

LICENSE="MIT"
SLOT="2"
KEYWORDS=""
IUSE="minimal xinerama xpm"

DEPEND="x11-libs/libX11
        xinerama? ( x11-libs/libXinerama )
        xpm? ( x11-libs/libXpm )"
RDEPEND="${DEPEND}"

src_unpack() {
    subversion_src_unpack

    cd "${S}"
    sed -e "s/\/usr\/local/\/usr/g" -e "s/-Os/${CFLAGS}/g" \
        -e "s/CC =.*/CC = $(tc-getCC | sed -e 's/\//\\\//g')/g" \
        -e "s/LD =.*/LD = $(tc-getCC | sed -e 's/\//\\\//g')/g" \
        -i config.mk || die "sed failed"

    if use xinerama ; then
        sed -e "/^LIBS/s/$/\ -lXinerama/" \
            -e "/^CFLAGS/s/$/\ -DDZEN_XINERAMA/" \
            -i config.mk || die "sed failed"
    fi
    if use xpm ; then
        sed -e "/^LIBS/s/$/\ -lXpm/" \
            -e "/^CFLAGS/s/$/\ -DDZEN_XPM/" \
            -i config.mk || die "sed failed"
    fi
}

src_install() {
    emake DESTDIR="${D}" install || die "emake install failed"
    dodoc README TODO
}

