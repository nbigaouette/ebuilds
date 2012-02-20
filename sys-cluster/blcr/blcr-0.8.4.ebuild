# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod

DESCRIPTION="Berkeley Lab Checkpoint/Restart for Linux"
HOMEPAGE="https://ftg.lbl.gov/projects/CheckpointRestart/"
SRC_URI="http://ftg.lbl.gov/assets/projects/CheckpointRestart/downloads/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="!>=sys-kernel/gentoo-sources-2.6.39"
RDEPEND=""

MAKEOPTS="${MAKEOPTS} -j1"

pkg_setup() {
    ewarn
    ewarn "This package is known to have issues with the sandbox"
    ewarn "If you experience problems, please re-emerge with:"
    ewarn "FEATURES=\"-sandbox -usersandbox\""
    ewarn
	linux-mod_pkg_setup
	MODULE_NAMES="blcr(blcr::${S}/cr_module/kbuild)
		blcr_imports(blcr::${S}/blcr_imports/kbuild)"
	BUILD_TARGETS="clean all"
    # --with-kernel flag does not exists! The closest is --with-kernel-type, but it's unrelated...
    # Use --with-linux* instead.
	#ECONF_PARAMS="--with-kernel=${KV_DIR}"
	ECONF_PARAMS="--with-linux=${KV_DIR} --with-linux-src=${KV_DIR}"
}

src_install() {
	dodoc README NEWS
	cd "${S}"/util
	emake DESTDIR="${D}" install || die "binaries install failed"
	cd "${S}"/libcr
	emake DESTDIR="${D}" install || die "libcr install failed"
	cd "${S}"/man
	emake DESTDIR="${D}" install || die "man install failed"
	cd "${S}"/include
	emake DESTDIR="${D}" install || die "headers install failed"
	linux-mod_src_install
}

pkg_postinst() {
	linux-mod_pkg_postinst
	einfo "Be sure to add blcr to your modules.autoload.d to"
	einfo "ensure that the modules get loaded on your next boot"
}
