# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit rpm

DESCRIPTION="LSI MegaRAID MegaCLI"
HOMEPAGE="http://www.lsi.com"

SRC_URI="http://www.lsi.com/downloads/Public/MegaRAID%20Common%20Files/${PV}_MegaCLI.zip"
LICENSE="LSI"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
app-arch/unzip"

RESTRICT="fetch"
QA_PRESTRIPPED="
    opt/MegaRAID/MegaCli/MegaCli*
    opt/MegaRAID/MegaCli/*.so*"

S="${WORKDIR}"

pkg_nofetch () {
    ewarn "Please visit http://www.lsi.com/search/Pages/downloads.aspx"
    ewarn "then search and download ${PV}_MegaCLI.zip"
    ewarn "Place the file in ${DISTDIR}"
}

src_unpack () {
    unpack ${A}
    unzip ./CLI_Lin_${PV}.zip || die "Failed to unzip CLI_Lin_${PV}.zip"
    unzip ./MegaCliLin.zip || die "Failed to unzip MegaCliLin.zip"
    rpm_unpack ./MegaCli-${PV}-1.noarch.rpm || die "Failed to rpm_unpack MegaCli-${PV}-1.noarch.rpm"
}

src_install() {
    insinto /opt/MegaRAID/MegaCli
    insopts -m0755
    if use x86; then
        doins opt/MegaRAID/MegaCli/MegaCli
        dosym /opt/MegaRAID/MegaCli/MegaCli /usr/bin/megacli
    elif use amd64; then
        doins opt/MegaRAID/MegaCli/MegaCli64
        dosym /opt/MegaRAID/MegaCli/MegaCli64 /usr/bin/megacli
    fi
    insopts -m0444
    doins opt/MegaRAID/MegaCli/libstorelibir*.so*
}

pkg_postinst() {
    elog "For usage, please refer to the \"MegaRAID SAS Software User Guide\"."
    elog "You can download it by visiting http://www.lsi.com/search/Pages/downloads.aspx"
    elog "and searching for it."
}
