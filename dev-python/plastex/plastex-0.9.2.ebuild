# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="3"
PYTHON_DEPEND="*"
SUPPORT_PYTHON_ABIS="1" 

# inherit distutils eutils
inherit distutils python eutils

DESCRIPTION="plasTeX is a LaTeX document processing framework written entirely in Python."
HOMEPAGE="http://plastex.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}/rel-${PV//./-}/${P}.tgz"

IUSE=""
SLOT="0"
KEYWORDS="~amd64"
LICENSE="plastex"

DEPEND=""
RDEPEND=""

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")
PYTHON_CXXFLAGS=("2.* + -fno-strict-aliasing")

PYTHON_MODNAME="plastex"

S=${WORKDIR}/${PN}
