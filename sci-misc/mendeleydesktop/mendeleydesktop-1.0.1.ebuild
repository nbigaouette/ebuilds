# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# http://bugs.gentoo.org/show_bug.cgi?id=308509

EAPI=4

inherit eutils

if [ "${ARCH}" = "amd64" ] ; then
    LNXARCH="linux-x86_64"
else
    LNXARCH="linux-i486"
fi

DESCRIPTION="A free research management tool for desktop & web"
HOMEPAGE="http://www.mendeley.com/"
SRC_URI="${HOMEPAGE}/downloads/linux/${P}-${LNXARCH}.tar.bz2"

LICENSE="Mendelay-EULA"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""
RESTRICT="mirror strip"
RDEPEND="
    media-libs/libpng:1.2
    dev-libs/openssl:0.9.8"

# S="${WORKDIR}/${P}-${LNXARCH}"
S="${WORKDIR}/${PN}-${PV:0:3}-${LNXARCH}"

MENDELEY_INSTALL_DIR="/opt/${PN}"

src_install() {
    # install menu
    domenu "share/applications/${PN}.desktop"
    # Install commonly used icon sizes
    for res in 16x16 22x22 32x32 48x48 64x64 128x128 ; do
        insinto "/usr/share/icons/hicolor/${res}/apps"
        doins "share/icons/hicolor/${res}/apps/${PN}.png" || \
        die "Installing icons failed."
    done
    insinto "/usr/share/pixmaps"
    doins "share/icons/hicolor/48x48/apps/${PN}.png" || \
    die "Installing pixmap failed."

    # dodoc
    dodoc "share/doc/${PN}/"* || die "Installing docs failed."

    # create directories for installation
    dodir ${MENDELEY_INSTALL_DIR} || die "dodir failed"
    dodir "${MENDELEY_INSTALL_DIR}/lib" || die "dodir failed"
    dodir "${MENDELEY_INSTALL_DIR}/share" || die "dodir failed"

    # install binaries
    mv "bin" "${D}${MENDELEY_INSTALL_DIR}" || die "Installing bin failed."
    mv "lib" "${D}${MENDELEY_INSTALL_DIR}" || die "Installing libs failed."
    mv "share/${PN}" "${D}${MENDELEY_INSTALL_DIR}/share" || \
    die "Installing shared files failed."
    dosym "${MENDELEY_INSTALL_DIR}/bin/${PN}" "/opt/bin/${PN}" || \
    die "Installing launcher symlinks failed."
}
