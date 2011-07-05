# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
inherit eutils

DESCRIPTION="Aggregate IPMI data for use in the Microway Cluster Management System."
HOMEPAGE="http://www.microway.com"
SRC_URI="ftp://ftp.microway.com/mcms/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="sys-libs/openipmi"
RDEPEND="${DEPEND}"

src_prepare() {
    epatch "${FILESDIR}/${P}-0001-Bug-fix-buffer-overflow-allocate-one-extra-character.patch"
    epatch "${FILESDIR}/${P}-0002-Bug-fix-buffer-overflow-allocate-one-extra-character.patch"
    epatch "${FILESDIR}/${P}-0003-Default-data-dir-changed-to-var-www-localhost-htdocs.patch"
    epatch "${FILESDIR}/${P}-0005-Added-comment-about-uninitialised-value-in-ipmi_ip_s.patch"
    epatch "${FILESDIR}/${P}-0006-Added-option-to-install-into-different-directory-by-.patch"
}

src_compile() {
    emake
}

src_install() {
    #mkdir -p ${D}/{usr/sbin,etc/init.d} || die
    #emake DESTDIR="${D}/usr/sbin" install
    dosbin ipmimon || die
    insinto /etc/init.d || die
    insopts -m0755
    newins "${FILESDIR}/${P}.initd" ipmimon || die
}

