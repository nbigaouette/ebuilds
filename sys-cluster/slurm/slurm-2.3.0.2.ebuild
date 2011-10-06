# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

RESTRICT="primaryuri"

EAPI=4
inherit eutils versionator pam

MY_PV=$(replace_version_separator 3 '-')
MY_P="${PN}-${MY_PV}"


DESCRIPTION="SLURM: A Highly Scalable Resource Manager"
HOMEPAGE="https://computing.llnl.gov/linux/slurm/"
SRC_URI="http://www.schedmd.com/download/latest/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="maui +munge mysql pam postgres ssl static-libs ypbind"

DEPEND="
    !sys-cluster/torque
    !net-analyzer/slurm
    mysql? ( dev-db/mysql )
    munge? ( sys-auth/munge )
    ypbind? ( net-nds/ypbind )
    pam? ( virtual/pam )
    postgres? ( dev-db/postgresql-base )
    ssl? ( dev-libs/openssl )
    >=sys-apps/hwloc-1.1.1-r1"
RDEPEND="${DEPEND}
    maui? ( sys-cluster/maui[slurm] )"


S="${WORKDIR}/${MY_P}"

pkg_setup() {
    enewgroup slurm 500
    enewuser slurm 500 -1 /var/spool/slurm slurm
}

src_prepare() {
    # gentoo uses /sys/fs/cgroup instead of /dev/cgroup
    sed -e 's:/dev/cgroup:/sys/fs/cgroup:g' \
        -i "${S}/doc/man/man5/cgroup.conf.5" \
        -i "${S}/etc/cgroup.conf.example" \
        -i "${S}/etc/cgroup.release_common.example" \
        -i "${S}/src/common/xcgroup.h" \
        || die
    # and pids should go to /var/run/slurm
    sed -e 's:/var/run/slurmctld.pid:/var/run/slurm/slurmctld.pid:g' \
        -e 's:/var/run/slurmd.pid:/var/run/slurm/slurmd.pid:g' \
        -i "${S}/etc/slurm.conf.example"
    # also state dirs are in /var/spool/slurm
    sed -e 's:StateSaveLocation=/tmp:StateSaveLocation=/var/spool/slurm:g' \
        -e 's:SlurmdSpoolDir=/tmp/slurmd:SlurmdSpoolDir=/var/spool/slurm/slurmd:g' \
        -i "${S}/etc/slurm.conf.example"
}

src_configure() {
    local myconf=(
            --sysconfdir="${EPREFIX}/etc/${PN}"
            --with-hwloc="${EPREFIX}/usr"
            --docdir="${EPREFIX}/usr/share/doc/${P}"
            --htmldir="${EPREFIX}/usr/share/doc/${P}"
            )
    use pam && myconf+=( --with-pam_dir=$(getpam_mod_dir) )
    use mysql || myconf+=( --without-mysql_config )
    use postgres || myconf+=( --without-pg_config )
    econf "${myconf[@]}" \
        $(use_enable pam) \
        $(use_with ssl) \
        $(use_with munge) \
        $(use_enable static-libs static)

    # --htmldir does not seems to propagate... Documentations are installed
    # in /usr/share/doc/slurm-2.3.0/html
    # instead of /usr/share/doc/slurm-2.3.0.2/html
    sed -e "s|htmldir = .*/html|htmldir = \${prefix}/share/doc/slurm-${PV}/html|g" -i doc/html/Makefile || die
}

src_compile() {
    default
    use pam && emake -C contribs/pam || die
}

src_install() {
    default
    emake DESTDIR="${D}" -C contribs/torque install || die
    use pam && emake DESTDIR="${D}" -C contribs/pam install || die
    use static-libs || find "${ED}" -name '*.la' -exec rm {} +
    # we dont need it
    rm "${ED}/usr/bin/mpiexec" || die
    # install sample configs
    keepdir /etc/slurm
    keepdir /var/log/slurm
    keepdir /var/spool/slurm
    keepdir /var/run/slurm
    insinto /etc/slurm
    doins etc/cgroup.conf.example
    doins etc/federation.conf.example
    doins etc/slurm.conf.example
    doins etc/slurmdbd.conf.example
    exeinto /etc/slurm
    doexe etc/cgroup.release_common.example
    doexe etc/slurm.epilog.clean
    # install init.d files
    newinitd "${FILESDIR}/slurmd.initd" slurmd
    newinitd "${FILESDIR}/slurmctld.initd" slurmctld
    newinitd "${FILESDIR}/slurmdbd.initd" slurmdbd
    # install conf.d files
    newconfd "${FILESDIR}/slurm.confd" slurm
}

pkg_preinst() {
    if use munge; then
        sed -i 's,\(SLURM_USE_MUNGE=\).*,\11,' "${D}"etc/conf.d/slurm || die
    fi
    if use ypbind; then
        sed -i 's,\(SLURM_USE_YPBIND=\).*,\11,' "${D}"etc/conf.d/slurm || die
    fi
}

create_folders_and_fix_permissions() {
    einfo "Fixing permissions in ${@}"
    mkdir -p ${@}
    chown -R ${PN}:${PN} ${@}
}

pkg_postinst() {
    paths=(/var/${PN}/checkpoint
            /var/${PN}
            /var/spool/${PN}
            /var/spool/${PN}/slurmd
            /var/run/${PN}
            /var/log/${PN}
            /tmp/${PN}/${PN}d
            /tmp/${PN})
    for folder_path in ${paths[@]}; do
        create_folders_and_fix_permissions $folder_path
    done
    echo

    elog "Please visit the file '/usr/share/doc/${P}/html/configurator.html"
    elog "through a (javascript enabled) browser to create a configureation file."
    elog "Copy that file to /etc/slurm/slurm.conf on all nodes (including the headnode) of your cluster."
    echo
    ewarn "Paths were created for slurm. Please use these paths in /etc/slurm/slurm.conf:"
    for folder_path in ${paths[@]}; do
    ewarn "    ${folder_path}"
    done
}
