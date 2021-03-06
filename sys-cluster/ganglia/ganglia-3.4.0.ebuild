# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/ganglia/ganglia-3.2.0.ebuild,v 1.4 2012/02/01 17:03:47 ranger Exp $

EAPI=4

PYTHON_DEPEND="python? 2"

inherit eutils multilib python

DESCRIPTION="A scalable distributed monitoring system for clusters and grids"
HOMEPAGE="http://ganglia.sourceforge.net/"
SRC_URI="mirror://sourceforge/ganglia/${P}.tar.gz"
LICENSE="BSD"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="vhosts pcre python examples"

DEPEND="dev-libs/confuse
	dev-libs/expat
	>=dev-libs/apr-1.0
	!dev-db/firebird
	pcre? ( dev-libs/libpcre )"

RDEPEND="
	${DEPEND}
	net-analyzer/rrdtool
	dev-lang/php[gd,xml,ctype,cgi]
	|| ( <dev-lang/php-5.3[pcre] >=dev-lang/php-5.3 )
	media-fonts/dejavu"

pkg_setup() {
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_prepare() {
	# Disable modpython by default (#358359)
	sed -i '/ *params/N;s,\( *\)\(params = "[^"]*"\),\1\2\n\1enabled = no,' \
		gmond/modules/conf.d/modpython.conf.in || die
}

src_configure() {
	econf \
		--enable-gexec \
		--sysconfdir="${EPREFIX}"/etc/${PN} \
		$(use_enable python) \
		$(use_with pcre libpcre) \
		--with-gmetad
}

src_install() {
	local exdir=/usr/share/doc/${P}

	emake DESTDIR="${D}" install || die

	newinitd "${FILESDIR}"/gmond.rc-2 gmond
	doman {mans/*.1,gmond/*.5} || die "Failed to install manpages"
	dodoc AUTHORS INSTALL NEWS README* || die

	dodir /etc/ganglia/conf.d
	use python && dodir /usr/$(get_libdir)/ganglia/python_modules
	gmond/gmond -t > "${ED}"/etc/ganglia/gmond.conf

	if use examples; then
		insinto ${exdir}/cmod-examples
		doins gmond/modules/example/*.c
		if use python; then
			# Installing as an examples per upstream.
			insinto ${exdir}/pymod-examples
			doins gmond/python_modules/*/*.py
			insinto ${exdir}/pymod-examples/conf.d
			doins gmond/python_modules/conf.d/*.pyconf
		fi
	fi

	insinto /etc/ganglia
	doins gmetad/gmetad.conf
	doman mans/gmetad.1

	newinitd "${FILESDIR}"/gmetad.rc-2 gmetad
	keepdir /var/lib/ganglia/rrds
	fowners nobody:nobody /var/lib/ganglia/rrds
}

pkg_postinst() {
	elog "A default configuration file for gmond has been generated"
	elog "for you as a template by running:"
	elog "    /usr/sbin/gmond -t > /etc/ganglia/gmond.conf"

	local dwoo_stat=$(stat --format %U:%G:%a ${ROOT}var/lib/ganglia/dwoo)
	if [[ ${dwoo_stat} == nobody:nobody:777 ]]; then
		elog
		elog "${ROOT}var/lib/ganglia/dwoo is owned by nobody:nobody with permissions 777"
		elog "You may wish to change this to only be writable by the webserver user"
		elog
	fi
}
