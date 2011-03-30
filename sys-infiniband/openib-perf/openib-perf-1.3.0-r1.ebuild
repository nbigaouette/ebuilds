# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

OFED_VER="1.5.3"
OFED_PATCH=".1"
OFED_SUFFIX="0.42.gf350d3d"

inherit openib

DESCRIPTION="OpenIB uverbs micro-benchmarks"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=sys-infiniband/libibverbs-1.1.4-r1
		>=sys-infiniband/librdmacm-1.0.14.1"

# src_unpack() {
#     unpack ${A} || die "unpack failed"
#     rpm_unpack "./OFED-${OFED_VER}/SRPMS/${MY_PN}-${MY_PV}-${OFED_SUFFIX}.src.rpm"
#     unpack ./${MY_PN}-${MY_PV}-${OFED_SUFFIX}.${EXT}
# }


src_compile() {
	emake || die "emake failed"
}

src_install() {
	dodoc README runme
	dobin ib_*
}

