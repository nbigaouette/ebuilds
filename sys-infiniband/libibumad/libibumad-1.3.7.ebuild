# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

OFED_VER="1.5.3.1"
OFED_SUFFIX="1"

inherit openib

DESCRIPTION="OpenIB User MAD library functions which sit on top of the user MAD modules in the kernel."
KEYWORDS="~amd64 ~x86"
IUSE=""

#DEPEND=">=sys-infiniband/libibcommon-1.1.2_p20090314"
DEPEND="" # libibcommon diseappeared from SRPM folder?
RDEPEND="${DEPEND}"

src_install() {
    make DESTDIR="${D}" install || die "install failed"
}
