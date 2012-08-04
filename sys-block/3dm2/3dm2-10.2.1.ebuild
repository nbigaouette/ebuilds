# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit eutils

MY_REV=9.5.4
MY_SRC='http://www.lsi.com/channel/support/pages/downloads.aspx?k=*&r=productfamily="AQUzd2FyZQ1wcm9kdWN0ZmFtaWx5AQFeASQ="%20os="AQVMaW51eAJvcwEBXgEk"%20assettype="AQhTb2Z0d2FyZQlhc3NldHR5cGUBAV4BJA=="'
MY_ARCH="${ARCH/amd64/x86_64}"

DESCRIPTION="3ware Disk Managment web utility and RAID controller CLI tool"
HOMEPAGE="http://www.lsi.com/"
SRC_URI="3DM2_CLI-Linux_${PV}_${MY_REV}.zip"

LICENSE="LSI"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="cli +web"

RESTRICT="mirror fetch"
PROPERTIES="interactive"

RDEPEND="virtual/libc
	virtual/logger
	virtual/mta"

DEPEND="cli? ( !sys-block/tw_cli )"

S=${WORKDIR}

pkg_nofetch() {
	einfo "This software can no longer be automatically downloaded."
	echo
	einfo "Please manually download the following file:"
	einfo "3DM2 CLI Linux from the ${PV}/${MY_REV} code set - non-java based installer"
	echo
	einfo "from the following URL:"
	einfo "${MY_SRC}"
	echo
	einfo "and move to: ${DISTDIR}/${SRC_URI}"
}

pkg_setup() {
	# Validate USE flags
	if (! use cli && ! use web); then
		ewarn
		ewarn "You must specify at least one USE flag for this package."
		ewarn
		die "No USE flags enabled."
	fi

	# Display some supplimental information about controller support
	echo
	einfo "This binary supports should support all 3ware controllers, including:"
	einfo "PATA: 6xxx, 72xx, 74xx, 78xx, 7000, 7500, 7506"
	einfo "SATA: 8006, 8500, 8506, 9500S, 9550SX, 9590SE"
	einfo "      9550SXU, 9650SE, 9690SA"
	echo
}

src_unpack() {
	unpack ${A}
	tar zxf tdmCliLnx.tgz
	mkdir help msg
	tar zxf tdm2Help.tgz -C help
	tar zxf tdm2Msg.tgz -C msg
}

src_prepare() {
	# update conf paths for Gentoo standards
	sed -i -e 's;MsgPath /opt/3ware/3DM2/msg;MsgPath /usr/share/3dm2/msg;' \
		-e 's;Help /opt/3ware/3DM2/help;Help /usr/share/3dm2/help;' \
		-e 's;imgPath /etc/3dm2;imgPath /usr/share/3dm2;' \
		3dm2.conf || die "sed update 3dm2.conf"
}

src_install() {
	if use web; then
		newsbin "3dm2.${MY_ARCH}" ${PN} || die "dosbin 3dm2.${MY_ARCH}"

		dodir /etc/${PN}
		insinto /etc/${PN}
		doins 3dm2.conf || die "doins 3dm2.conf"

		insinto /usr/share/${PN}
		doins logo.gif || die "doins logo.gif"
		doins -r help || die "doins help"
		doins -r msg || die "doins msg"

		newinitd "${FILESDIR}/${PN}.init" ${PN} || die "newinitd 3dm2.init"
	fi

	if use cli; then
		newsbin tw_cli.${MY_ARCH} tw_cli || die "dosbin tw_cli.${MY_ARCH}"
		newman tw_cli.8.nroff tw_cli.8
		dodoc tw_cli.8.html
	fi

	dodoc LGPL_License.txt OpenSSL.txt
}

pkg_preinst() {
	RESTART=0
	if use web; then
		if [ $(pgrep 3dm2 >/dev/null; echo $?) -eq 0 ]; then
			/etc/init.d/${PN} stop
			RESTART=1
		fi
	fi
}

pkg_postinst() {
	if [ ${RESTART} -eq 0 ]; then
		echo
		einfo "Start 3dm2, then connect to the server at https://localhost:888/"
		einfo "Default password for both user and administrator is: 3ware"
		einfo "Note that remote access is *enabled* by default."
		einfo
		einfo "To change the ssl cert, place a file called 3dm2.pem in /etc/3dm2"
		einfo "It must contain the certificate and the key."
		einfo "Under normal circumstances you don't need to change it."
	else
		echo
		ewarn "Note: 3dm2 was automatically stopped to complete this upgrade."
		ewarn "You should restart it now with: /etc/init.d/${PN} start"
	fi
	echo
}

