# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# http://bugs.gentoo.org/show_bug.cgi?id=308509

EAPI=4

inherit eutils

if use amd64; then
    LNXARCH="linux-x86_64"
elif use x86; then
    LNXARCH="linux-i486"
fi

DESCRIPTION="A free research management tool for desktop & web"
HOMEPAGE="http://www.mendeley.com/"

SRC_URI="http://download.mendeley.com/linux/${P}-${LNXARCH}.tar.bz2"

LICENSE="Mendelay-EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror strip"
# RDEPEND="
#     media-libs/libpng:1.2
#     dev-libs/openssl:0.9.8"
RDEPEND="x11-libs/qt-core:4
         x11-libs/qt-gui:4
         x11-libs/qt-svg:4
         x11-libs/qt-webkit:4
         x11-libs/qt-xmlpatterns:4
         dev-lang/python:2.7"
DEPEND="${RDEPEND}"


S="${WORKDIR}/${P}-${LNXARCH}"
# S="${WORKDIR}/${PN}-${PV:0:3}-${LNXARCH}"

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

    # Delete bundled Qt
    rm -fr ${D}${MENDELEY_INSTALL_DIR}/lib/qt || die "Can't delete qt folder"
}
