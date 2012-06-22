# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="A powerful and highly parallelized molecular dynamics code"
LICENSE="namd"
HOMEPAGE="http://www.ks.uiuc.edu/Research/namd/"

MY_PN="NAMD"

SRC_URI="${MY_PN}_${PV}_Source.tar.gz"

SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda"

RESTRICT="fetch"

DEPEND="
	app-shells/tcsh
	sys-cluster/charm
	=sci-libs/fftw-2*
	dev-lang/tcl
	app-shells/tcsh
	cuda? (
		>=x11-drivers/nvidia-drivers-270.41.19
		>=dev-util/nvidia-cuda-toolkit-4.0
	)"

RDEPEND=${DEPEND}

NAMD_ARCH="Linux-x86_64-g++"

NAMD_DOWNLOAD="http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD"

S="${WORKDIR}/${MY_PN}_${PV}_Source"

pkg_nofetch() {
	echo
	einfo "Please download ${MY_PN}_${PV}_Source.tar.gz from"
	einfo "${NAMD_DOWNLOAD}"
	einfo "after agreeing to the license and then move it to"
	einfo "${DISTDIR}"
	einfo "Be sure to select the ${PV} version!"
	echo
}

src_prepare() {

	CHARM_VERSION=$(best_version sys-cluster/charm | cut -d- -f3)
	elog "Using CHARM_VERSION=$CHARM_VERSION"
	rm -f charm-*.tar || die

	sed -e "s|CHARMBASE = .*|CHARMBASE = /usr/include/charm-$CHARM_VERSION|g" -i Make.charm

	# apply a few small fixes to make NAMD compile and
	# link to the proper libraries
	epatch "${FILESDIR}"/namd-2.9-gentoo.patch
	epatch "${FILESDIR}"/namd-2.9-ldflags.patch
	#epatch "${FILESDIR}"/namd-2.7-iml-dec.patch

	# proper compiler and cflags
	sed -e "s/g++/$(tc-getCXX)/" \
		-e "s/gcc/$(tc-getCC)/" \
		-e "s/CXXOPTS = .*/CXXOPTS = ${CXXFLAGS}/" \
		-e "s/COPTS = .*/COPTS = ${CFLAGS}/" \
		-i arch/${NAMD_ARCH}.arch || \
		die "Failed to setup ${NAMD_ARCH}.arch"
		#-e "s/CXXOPTS = -O3 -m64 -fexpensive-optimizations -ffast-math/CXXOPTS = ${CXXFLAGS}/" \
		#-e "s/COPTS = -O3 -m64 -fexpensive-optimizations -ffast-math/COPTS = ${CFLAGS}/" \

	sed -e "s/gentoo-libdir/$(get_libdir)/g" \
		-e "s/gentoo-charm/charm-${CHARM_VERSION}/g" \
		-i Makefile || die "Failed gentooizing Makefile."
	sed -e "s/gentoo-libdir/$(get_libdir)/g" -i arch/Linux-x86_64.fftw || \
		die "Failed gentooizing Linux-x86_64.fftw."
	sed -e "s/gentoo-libdir/$(get_libdir)/g" -i arch/Linux-x86_64.tcl || \
		die "Failed gentooizing Linux-x86_64.tcl."

    # Make sure "obj" directory exists
    mkdir obj
}

src_configure() {
	if use cuda; then
		CONFIG_OPTIONS="--with-cuda --cuda-prefix /opt/cuda"
	fi

	# configure
	./config ${NAMD_ARCH} ${CONFIG_OPTIONS}
}

src_compile() {
	# build namd
	cd "${S}/${NAMD_ARCH}"
	emake -j 1
}

src_install() {
	cd "${S}/${NAMD_ARCH}"

	# the binaries
	dobin ${PN}2 psfgen flipbinpdb flipdcd || \
		die "Failed to install binaries"

	cd "${S}"

	# some docs
	dodoc announce.txt license.txt notes.txt || \
		die "Failed to install docs"
}

pkg_postinst() {
	echo
	einfo "For detailed instructions on how to run and configure"
	einfo "NAMD please consults the extensive documentation at"
	einfo "http://www.ks.uiuc.edu/Research/namd/"
	einfo "and the NAMD tutorials available at"
	einfo "http://www.ks.uiuc.edu/Training/Tutorials/"
	einfo "Have fun :)"
	echo
}
