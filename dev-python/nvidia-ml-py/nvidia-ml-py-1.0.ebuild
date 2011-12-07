# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

EAPI=3

PYTHON_DEPEND="*"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils

DESCRIPTION="Python Bindings for the NVIDIA Management Library"
HOMEPAGE="http://pypi.python.org/pypi/nvidia-ml-py/"
SRC_URI="http://pypi.python.org/packages/source/n/nvidia-ml-py/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="x11-drivers/nvidia-drivers"
DEPEND="${RDEPEND}"
