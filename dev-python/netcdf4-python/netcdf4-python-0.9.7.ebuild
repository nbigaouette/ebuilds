# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

EAPI=3

PYTHON_DEPEND="*"
SUPPORT_PYTHON_ABIS="1"

inherit distutils flag-o-matic fortran-2 toolchain-funcs versionator

My_P=netCDF4

DESCRIPTION="Read and write files in both the new netCDF 4 and the old netCDF 3 format, and can create files that are readable by HDF5 clients."
HOMEPAGE="https://code.google.com/p/${PN}/"
SRC_URI="https://${PN}.googlecode.com/files/${My_P}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

RDEPEND="
    dev-python/setuptools
    sci-libs/netcdf[hdf5]
    sci-libs/hdf5[szip]"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${My_P}-${PV}"


src_test() {
    testing() {
        cd test || die "Can't find 'test' directory."
        PYTHONPATH="$(ls -d ${S}/build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" run_all.py || die "Running test fail"
    }
    python_execute_function testing
}

