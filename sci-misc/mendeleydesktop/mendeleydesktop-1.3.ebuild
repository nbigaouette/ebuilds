# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# http://bugs.gentoo.org/show_bug.cgi?id=308509

EAPI=4

inherit eutils

ARCHIVE_BASE="${P}-linux-BASE.tar.bz2"
ARCHIVE_X86="${ARCHIVE_BASE/BASE/i486}"
ARCHIVE_AMD64="${ARCHIVE_BASE/BASE/x86_64}"

DESCRIPTION="A free research management tool for desktop & web"
HOMEPAGE="http://www.mendeley.com/"

SRC_URI="
    x86?   ( http://download.mendeley.com/linux/${ARCHIVE_X86}   )
    amd64? ( http://download.mendeley.com/linux/${ARCHIVE_AMD64} )
"

LICENSE="Mendelay-EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt-bundled"
RESTRICT="mirror strip"
# RDEPEND="
#     media-libs/libpng:1.2
#     dev-libs/openssl:0.9.8"
RDEPEND="
    !qt-bundled? (
        <x11-libs/qt-core-4.8
        <x11-libs/qt-gui-4.8
        <x11-libs/qt-svg-4.8
        <x11-libs/qt-webkit-4.8
        <x11-libs/qt-xmlpatterns-4.8
    )
         dev-lang/python:2.7"
DEPEND="${RDEPEND}"


if   [[ "${ARCH}" == "x86" ]]; then
    S=${WORKDIR}/${ARCHIVE_X86/.tar.bz2/}
elif [[ "${ARCH}" == "amd64" ]]; then
    S=${WORKDIR}/${ARCHIVE_AMD64/.tar.bz2/}
fi

MENDELEY_INSTALL_DIR="/opt/${PN}"

src_install() {
    # install menu
    domenu "share/applications/${PN}.desktop"
    # Install commonly used icon sizes
    for res in 16x16 22x22 32x32 48x48 64x64 128x128 ; do
        insinto "/usr/share/icons/hicolor/${res}/apps"
        doins "share/icons/hicolor/${res}/apps/${PN}.png"
    done
    insinto "/usr/share/pixmaps"
    doins "share/icons/hicolor/48x48/apps/${PN}.png"

    # dodoc
    dodoc "share/doc/${PN}/"*

    # create directories for installation
    dodir ${MENDELEY_INSTALL_DIR}
    dodir "${MENDELEY_INSTALL_DIR}/lib"
    dodir "${MENDELEY_INSTALL_DIR}/share"

    # install binaries
    cp -r "bin" "${D}${MENDELEY_INSTALL_DIR}" || die "Can't copy bin directory"
    cp -r "lib" "${D}${MENDELEY_INSTALL_DIR}" || die "Can't copy lib directory"
    cp -r "share/${PN}" "${D}${MENDELEY_INSTALL_DIR}/share" || die "Can't copy share/${PN} directory"
    dosym "${MENDELEY_INSTALL_DIR}/bin/${PN}" "/usr/bin/${PN}"
    sed -i '1s@^#!/usr/bin/python$@&2@' ${D}${MENDELEY_INSTALL_DIR}/bin/${PN} || die "Can't sed for python2"

    if use qt-bundled; then
        sed -i 's/^Exec.*$/& --force-bundled-qt/' "${D}/usr/share/applications/${PN}.desktop" || die "Can't sed"
    else
        # Delete bundled Qt
        rm -fr ${D}${MENDELEY_INSTALL_DIR}/lib/qt || die "Can't delete qt folder"
    fi
}
