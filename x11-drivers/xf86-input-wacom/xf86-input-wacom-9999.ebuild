# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-input-wacom/xf86-input-wacom-0.10.0.ebuild,v 1.3 2009/11/05 22:54:58 remi Exp $

# http://gpo.zugaina.org/x11-drivers/xf86-input-wacom/Dep
# http://git.overlays.gentoo.org/gitweb/?p=dev/ikelos.git;a=blob_plain;f=x11-drivers/xf86-input-wacom/xf86-input-wacom-9999.ebuild;h=24db1d5691e739f035d1830264e2890d92bdf263;hb=1e779253eec1b42407dc2f1f1255af93b8adecc8

EAPI="4"

#inherit x-modular eutils autotools git-2
# inherit linux-info xorg-2 git-2
inherit linux-info xorg-2

DESCRIPTION="Driver for Wacom tablets and drawing devices"
LICENSE="GPL-2"
EGIT_REPO_URI="git://linuxwacom.git.sourceforge.net/gitroot/linuxwacom/xf86-input-wacom"
EGIT_BRANCH="master"
EGIT_TREE="master"
[[ ${PV} != 9999* ]] && \
    SRC_URI="mirror://sourceforge/linuxwacom/${PN}/${P}.tar.bz2"
SRC_URI=""

KEYWORDS="~amd64"
IUSE="debug"

RDEPEND="!x11-drivers/linuxwacom
        >=x11-base/xorg-server-1.7
        x11-libs/libX11
        x11-libs/libXext
        x11-libs/libXi
        x11-libs/libXrandr"
DEPEND="${RDEPEND}
    x11-proto/randrproto"

_obtain() {
    msg "Downloading $1/$2 from kernel ${_kernelver} sources..."
    _kernelrel=`echo ${_kernelver} | sed 's/\([0-9]*\.[0-9]*\.[0-9]*\).*/\1.y/'`
    _url="http://git.kernel.org/?p=linux/kernel/git/stable/linux-${_kernelrel}.git"
    wget "${_url};a=blob_plain;f=$1/$2;hb=refs/tags/v${_kernelver}" -O $2
}

pkg_setup()
{
    linux-info_pkg_setup

    XORG_CONFIGURE_OPTIONS=(
        $(use_enable debug)
    )
}

# src_prepare()
# {
#     eautoreconf
#     x-modular_src_prepare
# }
src_install() {
    xorg-2_src_install

    rm -rf "${D}"/usr/share/hal
}

pkg_pretend() {
    linux-info_pkg_setup

    if ! linux_config_exists \
            || ! linux_chkconfig_present TABLET_USB_WACOM \
            || ! linux_chkconfig_present INPUT_EVDEV; then
        echo
        ewarn "If you use a USB Wacom tablet, you need to enable support in your kernel"
        ewarn "  Device Drivers --->"
        ewarn "    Input device support --->"
        ewarn "      <*>   Event interface"
        ewarn "      [*]   Tablets  --->"
        ewarn "        <*>   Wacom Intuos/Graphire tablet support (USB)"
        echo
    fi
}
