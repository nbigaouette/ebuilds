# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/ganglia/ganglia-3.2.0.ebuild,v 1.4 2012/02/01 17:03:47 ranger Exp $

EAPI="3"

WEBAPP_MANUAL_SLOT="yes"

inherit eutils multilib webapp

DESCRIPTION="The web interface to sys-cluster/ganglia, a scalable distributed monitoring system for clusters and grids"
HOMEPAGE="http://ganglia.sourceforge.net/"
SRC_URI="mirror://sourceforge/ganglia/${P}.tar.gz"
LICENSE="BSD"

SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

DEPEND="
	dev-lang/php[xml]"

RDEPEND="
	${DEPEND}
	sys-cluster/ganglia"

pkg_setup() {
	webapp_pkg_setup
}

src_install() {
	local exdir=/usr/share/doc/${P}

	mkdir -p ${D}/usr/share/webapps/${PN}/${PV}
	emake -j1 DESTDIR="${D}" GDESTDIR="/usr/share/webapps/${PN}/${PV}/htdocs" install || die

	dodoc AUTHORS README* || die

	webapp_src_preinst
	webapp_src_install

	keepdir /var/lib/ganglia/dwoo
	fowners -R apache:apache /var/lib/ganglia/dwoo
	fperms 755 /var/lib/ganglia/dwoo
	fperms 755 /var/lib/ganglia/dwoo/compiled
	fperms 755 /var/lib/ganglia/dwoo/cached
}
