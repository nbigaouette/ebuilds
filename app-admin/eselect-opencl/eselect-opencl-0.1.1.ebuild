# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-opengl/eselect-opengl-1.1.1-r2.ebuild,v 1.7 2010/02/10 03:58:05 josejx Exp $

# Imported from http://gpo.zugaina.org/app-admin/eselect-opencl

EAPI="2"

inherit multilib

DESCRIPTION="Manages different OpenCL implementation installations using eselect."
HOMEPAGE="http://www.gentoo.org"

SRC_URI="https://github.com/nbigaouette/${PN}/tarball/${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="app-arch/bzip2"
RDEPEND=">=app-admin/eselect-1.2.4"

S="${WORKDIR}/nbigaouette-eselect-opencl-10c5ef0"

src_install() {
    insinto /usr/share/eselect/modules
    doins opencl.eselect || die
}
