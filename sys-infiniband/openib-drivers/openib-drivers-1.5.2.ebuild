# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit rpm linux-mod

DESCRIPTION="OpenIB kernel modules"
HOMEPAGE="http://www.openfabrics.org/"
SHORT_PV=${PV%\.[^.]}
SRC_URI="http://www.openfabrics.org/builds/ofed-${PV}/release/OFED-${PV}.tgz"
MY_P="OFED-${PV}"
S="${WORKDIR}/ofa_kernel-${PV}"

LICENSE="|| ( GPL-2 BSD-2 )"
SLOT="0"

KEYWORDS="~x86 ~amd64"
IUSE="memtrack hpage-patch srp ipath iser ehca mlx4 rds madeye vnic cxgb3 debug"

RDEPEND=""
PDEPEND="=sys-infiniband/openib-files-${PV}"
DEPEND="${RDEPEND}
    virtual/linux-sources"

pkg_setup() {

    CONFIG_CHECK="!INFINIBAND PCI"
    ERROR_INFINIBAND="Infiniband is already compiled into the kernel."
    ERROR_PCI="PCI must be enabled in the kernel."

    linux-mod_pkg_setup
}

src_unpack() {
    unpack ${A} || die "unpack failed"
    rpm_unpack ./${MY_P}/SRPMS/ofa_kernel-${PV}-OFED.${PV}..src.rpm
    tar xzf ofa_kernel-${PV}.tgz
    # remove patches that failed for me:
    rm "${S}/kernel_patches/backport/2.6.32/mlx4_semaphore_include.patch" \
       "${S}/kernel_patches/backport/2.6.32/net_skb-dst_accessors.patch" \
       "${S}/kernel_patches/backport/2.6.32/new_frags_interface.patch" \
       || die "Cannot find patch to delete. Please update list."
}

make_target() {
	local myARCH="${ARCH}" myABI="${ABI}"
	ARCH="$(tc-arch-kernel)"
	ABI="${KERNEL_ABI}"

	emake HOSTCC=$(tc-getBUILD_CC) CC=$(get-KERNEL_CC) $@ \
		|| die "Unable to run emake $@"

	ARCH="${myARCH}"
	ABI="${myABI}"
}

src_compile() {
	convert_to_m Makefile

	export CONFIG_INFINIBAND="m"
	export CONFIG_INFINIBAND_IPOIB="m"
	export CONFIG_INFINIBAND_SDP="m"
	export CONFIG_INFINIBAND_SRP="m"

	export CONFIG_INFINIBAND_USER_MAD="m"
	export CONFIG_INFINIBAND_USER_ACCESS="m"
	export CONFIG_INFINIBAND_ADDR_TRANS="y"
	export CONFIG_INFINIBAND_MTHCA="m"
	export CONFIG_INFINIBAND_IPATH="m"

	CONF_PARAMS="--prefix=${ROOT}usr --kernel-version=${KV_FULL}
				 --with-core-mod
				 --with-ipoib-mod
				 --with-ipoib-cm
				 --with-sdp-mod
				 --with-user_mad-mod
				 --with-user_access-mod
				 --with-addr_trans-mod
				 --with-mthca-mod"
	CONF_PARAMS="$CONF_PARAMS
			     $(use_with srp)-mod
			     $(use_with ipath)_inf-mod
			     $(use_with iser)-mod
			     $(use_with ehca)-mod
			     $(use_with mlx4)-mod
			     $(use_with rds)-mod
			     $(use_with madeye)-mod
			     $(use_with vnic)-mod
			     $(use_with cxgb3)-mod"
	if use debug; then
		CONF_PARAMS="$CONF_PARAMS
					 --with-mthca_debug-mod
					 --with-ipoib_debug-mod
					 --with-sdp_debug-mod
					 $(use_with srp)_debug-mod
					 $(use_with rds)_debug-mod
					 $(use_with vnic)_debug-mod
					 $(use_with mlx4)_debug-mod
					 $(use_with cxgb3)_debug-mod"
	else
		CONF_PARAMS="$CONF_PARAMS
					 --without-mthca_debug-mod
					 --without-ipoib_debug-mod
					 --without-sdp_debug-mod"
	fi
	ebegin "Configuring"
	local myARCH="${ARCH}" myABI="${ABI}"
	ARCH="$(tc-arch-kernel)"
	ABI="${KERNEL_ABI}"
	./configure ${CONF_PARAMS} ${EXTRA_ECONF} \
		|| die "configure failed with options: ${CONF_PARAMS}"
	ARCH="${myARCH}"
	ABI="${myABI}"
	eend

	#sed -i '/DEPMOD.*=.*depmod/s/=.*/= :/' ./Makefile
	#grep DEPMOD Makefile

	make_target
}

src_install() {

	make_target DESTDIR="${D}" install

	insinto /usr/include/rdma
	doins "${S}/include/rdma/*.h"
	insinto /usr/include/scsi
	doins "${S}/include/scsi/*.h"

}

pkg_postinst() {

	linux-mod_pkg_postinst

}
