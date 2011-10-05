# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# TODO:
#   Set use flags

RESTRICT="primaryuri"

EAPI="4"
inherit eutils versionator

MY_PV=$(replace_version_separator 3 '-')
MY_P="${PN}-${MY_PV}"


DESCRIPTION="The Simple Linux Utility for Resource Management (SLURM) is an open source, fault-tolerant, and highly scalable cluster management and job scheduling system for large and small Linux clusters."
HOMEPAGE="https://computing.llnl.gov/linux/slurm"
SRC_URI="http://www.schedmd.com/download/latest/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=("sys-auth/munge")

S="${WORKDIR}/${MY_P}"

src_install() {
    emake DESTDIR="${D}" install

    # Why etc files aren't installed?
    insinto /etc/${PN}
    doins etc/*

    [ -d "${D}"/etc/init.d ] && rm -r "${D}"/etc/init.d
    newinitd "${FILESDIR}/${PN}d.initd"    ${PN}d
    newinitd "${FILESDIR}/${PN}ctld.initd" ${PN}ctld
}

pkg_postinst() {
    elog "Please visit the file '/usr/share/doc/${P}/html/configurator.html' through a (javascript enabled) browser to create a configureation file."
    elog "Copy that file to /etc/slurm.conf on all nodes (including the headnode) of your cluster."
}
