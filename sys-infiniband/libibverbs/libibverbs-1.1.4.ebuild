# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

OFED_VER="1.5.2"
OFED_SUFFIX="0.14.gb6c138b"

inherit autotools eutils openib

DESCRIPTION="A library allowing programs to use InfiniBand 'verbs' for direct access to IB hardware"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-fs/sysfsutils"
RDEPEND="${DEPEND}
	!sys-infiniband/openib-userspace"

src_unpack() {
    unpack ${A} || die "unpack failed"
    rpm_unpack "./OFED-${OFED_VER}/SRPMS/${MY_PN}-${MY_PV}-${OFED_SUFFIX}.src.rpm"
    unpack ./${MY_PN}-${MY_PV}-${OFED_SUFFIX}.${EXT}
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-pcfile.patch
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc README AUTHORS ChangeLog || die
}
