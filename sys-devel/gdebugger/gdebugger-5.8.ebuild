# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit versionator

My_PN="gDEBugger"
My_PV=$(delete_all_version_separators)

DESCRIPTION="Advanced OpenGL and OpenCL Debugger, Profiler and Memory Analyzer."
HOMEPAGE="http://www.gremedy.com/"

if [[ "${ARCH}" == "amd64" ]]; then
    _arch="x86_64"
elif [[ "${ARCH}" == "x86" ]]; then
    _arch="i386"
fi

SRC_URI="
    x86?    ( http://files.gremedy.com/downloads/${My_PN}${My_PV}-i386.tar.gz )
    amd64?  ( http://files.gremedy.com/downloads/${My_PN}${My_PV}-x86_64.tar.gz )"

LICENSE="${My_PN}"
SLOT="0"
KEYWORDS="~amd64"


RDEPEND="virtual/libstdc++"
DEPEND="${RDEPEND} app-text/html2text"

RESTRICT="mirror strip"

S="${WORKDIR}/${My_PN}${PV//./}-${_arch}"
_destination=/opt/${My_PN}

src_install() {
    dodir /opt
    dodir /usr/bin
    dodir /usr/portage/licenses/
    dodir /usr/share/applications

    cd ..
    cp -a ${S} ${D}${_destination}
    #insinto /opt/${My_PN}
    #doins ${S}

    dosym ${_destination}/${My_PN} /usr/bin/

    html2text ${D}${_destination}/Legal/EndUserLicenseAgreement.htm > ${D}/usr/portage/licenses/${My_PN}.txt || die "Can't copy license"

    echo "[Desktop Entry]
Name=${My_PN}
Exec=${My_PN}
Type=Application
GenericName=OpenCL/OpenGL debugger
Terminal=false
Icon=${My_PN}
Caption=OpenCL/OpenGL debugger
Categories=Application;" > ${D}/usr/share/applications/${PN}.desktop || die "Can't create .desktop file"

    insinto /usr/share/icons/hicolor/64x64/apps/
    newins ${D}${_destination}/tutorial/images/applicationicon_64.jpg ${My_PN}.jpg
}
