# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

OFED_VER="1.5.2"
OFED_SUFFIX="1"

inherit openib

KEYWORDS="~x86 ~amd64"

DESCRIPTION="OpenIB Userspace CM library"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND=">=sys-infiniband/libibverbs-1.1.4"
DEPEND="${RDEPEND}"

src_install() {
	make DESTDIR="${D}" install || die "install failed"
	dodoc README AUTHORS ChangeLog
}
