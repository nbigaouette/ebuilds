# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

EGIT_REPO_URI="git://github.com/ganglia/gmond_python_modules.git"
EGIT_NONBARE="yes"
subfolder_path="gpu/nvidia"

inherit git-2 multilib

DESCRIPTION="NVIDIA GPU monitoring plugin for gmond"
HOMEPAGE="https://github.com/ganglia/gmond_python_modules/tree/master/${subfolder_path}"
SRC_URI=""

IUSE=""
SLOT="0"
KEYWORDS=""
LICENSE="PYTHON BSD"

DEPEND="sys-cluster/ganglia[python] dev-python/nvidia-ml-py"
RDEPEND="${DEPEND}"

src_install() {
    cd ${subfolder_path}
    insinto /usr/$(get_libdir)/ganglia/python_modules
    doins python_modules/nvidia.py

    insinto /etc/ganglia/conf.d
    doins conf.d/nvidia.pyconf

    # Need to source twice for "vhost_root" to be complete
    . /etc/vhosts/webapp-config
    . /etc/vhosts/webapp-config
    insinto ${vhost_root}/htdocs/ganglia/graph.d/
    doins graph.d/*

    elog "Please patch ganglia yourself using 'ganglia_web.patch'"
    elog "available from https://github.com/ganglia/gmond_python_modules/tree/master/${subfolder_path}"
    elog
    elog "# cd ${vhost_root}/htdocs/ganglia"
    elog "# patch -Np0 -i ${WORKDIR}/${PN}-${PV}/${subfolder_path}/ganglia_web.patch"
}
