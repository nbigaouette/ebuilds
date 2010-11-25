# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/icc/icc-11.1.046-r2.ebuild,v 1.3 2010/07/28 13:05:36 flameeyes Exp $

EAPI="2"

inherit toolchain-funcs

PID=1431
PB=cproc
DESCRIPTION="Intel C/C++ optimized compiler for Linux"
HOMEPAGE="http://www.intel.com/software/products/compilers/clin/"

###
# everything below common to ifc and icc
# no eclass: very likely to change for next versions
###
PACKAGEID="l_${PB}_p_${PV}"
RELEASE="${PV:0:4}"
BUILD="${PV:5:8}"
SRC_URI="http://registrationcenter-download.intel.com/irc_nas/${PID}/${PACKAGEID}.tgz"
#SRC_URI="amd64? ( http://registrationcenter-download.intel.com/irc_nas/${PID}/${PACKAGEID}_intel64.tgz )
#	ia64? ( http://registrationcenter-download.intel.com/irc_nas/${PID}/${PACKAGEID}_ia64.tgz )
#	x86?  ( http://registrationcenter-download.intel.com/irc_nas/${PID}/${PACKAGEID}_ia32.tgz )"

LICENSE="Intel-SDP"
SLOT="${PV}"
IUSE=""
KEYWORDS="~amd64 ~ia64"

RESTRICT="mirror strip"

INSTALL_DIR="opt/intel/Compiler/${RELEASE}/${BUILD}"
# these don't work, not sure why
#QA_TEXTRELS="${INSTALL_DIR}"
#QA_WX_LOAD="${INSTALL_DIR}"
#QA_PRESTRIPPED="${INSTALL_DIR}"

DEPEND="app-arch/rpm"
RDEPEND="~virtual/libstdc++-3.3
	amd64? ( app-emulation/emul-linux-x86-compat )"

S="${WORKDIR}/${PACKAGEID}"

src_prepare() {
	use amd64 || rm -f rpm/*x86_64.rpm
	# debugger installed with dev-lang/idb
	rm -f rpm/intel*idb*.rpm
	# performance primitives installed with sci-libs/ipp
	rm -f rpm/intel*ipp*.rpm
	# math library installed with sci-libs/mkl
	rm -f rpm/intel*mkl*.rpm
}

src_install() {
	mkdir "${WORKDIR}/rpmdb"
	# rpm open_wr's / but doesn't seem to do anything with it
	addpredict /
	rpm --install --nodeps --dbpath "${WORKDIR}/rpmdb" --prefix "${D}/${INSTALL_DIR}" rpm/*.rpm || die

	find "${D}/${INSTALL_DIR}" -name '*.csh' | xargs sed -i "s|${D}|${ROOT}|" || die
	find "${D}/${INSTALL_DIR}" -name '*.sh' | xargs sed -i "s|${D}|${ROOT}|" || die

# 	ENV_FILE=05${PN}
	MYARCH=""
	if use amd64; then MYARCH=intel64; fi
	if use ia64; then MYARCH=ia64; fi
	if use x86; then MYARCH=ia32; fi

	# By default, icpc 11.1 will prepend /usr to these paths, failing to find stdc++ headers
	cat <<EOF >> "${D}/${INSTALL_DIR}/bin/${MYARCH}/icpc.cfg"
-nostdinc++
-isystem/usr/lib/gcc/${CHOST}/$(gcc-fullversion)/include/g++-v4
-isystem/usr/lib/gcc/${CHOST}/$(gcc-fullversion)/include/g++-v4/${CHOST}
-isystem/usr/lib/gcc/${CHOST}/$(gcc-fullversion)/include/g++-v4/backward
EOF

# 	cat <<EOF > ${ENV_FILE}
# MANPATH=${ROOT}${INSTALL_DIR}/man/en_US
# INTEL_LICENSE_FILE=${ROOT}${INSTALL_DIR}/licenses:${ROOT}opt/intel/licenses
# LIBRARY_PATH=${ROOT}${INSTALL_DIR}/lib/intel64:${ROOT}${INSTALL_DIR}/tbb/em64t/cc4.1.0_libc2.4_kernel2.6.16.21/lib
# LD_LIBRARY_PATH=${ROOT}${INSTALL_DIR}/lib/intel64:${ROOT}${INSTALL_DIR}/tbb/em64t/cc4.1.0_libc2.4_kernel2.6.16.21/lib
# CPATH=${ROOT}${INSTALL_DIR}/tbb/include
# NLSPATH=${ROOT}${INSTALL_DIR}/lib/intel64/locale/%l_%t/%N
# PATH=${ROOT}${INSTALL_DIR}/bin/${MYARCH}
# ROOTPATH=${ROOT}${INSTALL_DIR}/bin/${MYARCH}
# DYLD_LIBRARY_PATH=${ROOT}${INSTALL_DIR}/tbb/em64t/cc4.1.0_libc2.4_kernel2.6.16.21/lib
# EOF
#
# 	doenvd ${ENV_FILE} || die

	keepdir /opt/intel/licenses
}

pkg_postinst() {
# 	env-update
	elog "${PN} requires a license file in order to run."
	elog "To receive a restrictive non-commercial license, please register at:"
	elog "http://www.intel.com/cd/software/products/asmo-na/eng/download/download/219771.htm"
	elog "Read the website for more information on this license."
	elog "Install the license file into ${ROOT}opt/intel/licenses"
	elog
	elog "The following packages provide components bundled with icc:"
	elog "\t dev-lang/idb"
	elog "\t sci-libs/ipp"
	elog "\t sci-libs/mkl"
	ewarn
	ewarn "The ${P} C++ compiler (icpc) is unable to find the GNU C++ headers on Gentoo."
	ewarn "To correct this, the following icpc options have been put in the file"
	ewarn "${ROOT}${INSTALL_DIR}/bin/${MYARCH}/icpc.cfg:"
	ewarn "\t -nostdinc++"
	ewarn "\t -isystem/usr/lib/gcc/${CHOST}/$(gcc-fullversion)/include/g++-v4"
	ewarn "\t -isystem/usr/lib/gcc/${CHOST}/$(gcc-fullversion)/include/g++-v4/${CHOST}"
	ewarn "\t -isystem/usr/lib/gcc/${CHOST}/$(gcc-fullversion)/include/g++-v4/backward"
	ewarn "You will have to update these lines every time you upgrade GCC for icpc to work."
	ewarn
}
