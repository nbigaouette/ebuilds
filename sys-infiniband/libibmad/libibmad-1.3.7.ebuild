# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

OFED_VER="1.5.3.1"
OFED_SUFFIX="1"

inherit openib

DESCRIPTION="OpenIB library providing low layer IB functions for use by the IB diagnostic/management programs"
KEYWORDS="~x86 ~amd64"
IUSE=""

# libibcommon disappeared from SRPMS folder?
#DEPEND=">=sys-infiniband/libibcommon-1.1.2_p20090314
DEPEND=">=sys-infiniband/libibumad-1.3.7"
RDEPEND="${DEPEND}"

src_install() {
    make DESTDIR="${D}" install || die "install failed"
}
