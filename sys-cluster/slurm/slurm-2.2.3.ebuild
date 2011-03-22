# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

DESCRIPTION="The Simple Linux Utility for Resource Management (SLURM) is an open source, fault-tolerant, and highly scalable cluster management and job scheduling system for large and small Linux clusters."
HOMEPAGE="https://computing.llnl.gov/linux/slurm"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=("sys-auth/munge")

# src_compile() {
#     #econf --with-posix-regex
#     econf
#     emake
# }
#
# src_install() {
#     emake DESTDIR="${D}" install || die
#
# #     dodoc FAQ NEWS README || die
# #     dohtml EXTENDING.html ctags.html
# }
