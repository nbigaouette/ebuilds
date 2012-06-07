# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/sparsehash/sparsehash-1.10.ebuild,v 1.2 2011/04/28 13:33:14 jlec Exp $

EAPI="4"

inherit eutils

DESCRIPTION="An extremely memory-efficient hash_map implementation"
HOMEPAGE="http://code.google.com/p/googlesparsehash/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_install() {
	default

	# Installs just every piece
	rm -rf "${D}/usr/share/doc"
	dohtml doc/*
}
