# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit flag-o-matic

DESCRIPTION="Performance Co-Pilot (PCP) provides a framework and services to support system-level performance monitoring and performance management."
HOMEPAGE="http://oss.sgi.com/projects/pcp/"
SRC_URI="ftp://oss.sgi.com/www/projects/pcp/download/${P}-1.src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
DEPEND=""
RDEPEND=""


pkg_setup() {
    # See http://blahg.josefsipek.net/?p=440
    append-flags $(no-as-needed)
    filter-flags -Wl,--as-needed
    filter-ldflags -Wl,--as-needed
    filter-ldflags --as-needed
    append-ldflags $(no-as-needed)
    filter-flags -fomit-frame-pointer
}

src_install() {
	DIST_ROOT="${D}" emake install
	dodoc CHANGELOG README
}
