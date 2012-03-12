# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

EGIT_REPO_URI="git://github.com/SchedMD/slurm.git"

inherit git-2 eutils versionator pam


DESCRIPTION="SLURM: A Highly Scalable Resource Manager"
HOMEPAGE="https://computing.llnl.gov/linux/slurm/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
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


pkg_setup() {
    enewgroup slurm 500
    enewuser slurm 500 -1 /var/spool/slurm slurm
}

src_prepare() {
    # Gentoo uses /sys/fs/cgroup instead of /cgroup
    # FIXME: Can the "^/cgroup" and "\([ =\"]\)/cgroup" patterns be merged?
    sed \
        -e 's|\([ =\"]\)/cgroup|\1/sys/fs/cgroup|g' \
        -e "s|^/cgroup|/sys/fs/cgroup|g" \
        -i "${S}/doc/man/man5/cgroup.conf.5" \
        -i "${S}/etc/cgroup.release_common.example" \
        -i "${S}/src/common/xcgroup_read_config.c" \
        || die "Can't sed /cgroup for /sys/fs/cgroup"
    # and pids should go to /var/run/slurm
    sed -e 's:/var/run/slurmctld.pid:/var/run/slurm/slurmctld.pid:g' \
        -e 's:/var/run/slurmd.pid:/var/run/slurm/slurmd.pid:g' \
        -i "${S}/etc/slurm.conf.example" \
        || die "Can't sed for /var/run/slurmctld.pid"
    # also state dirs are in /var/spool/slurm
    sed -e 's:StateSaveLocation=*.:StateSaveLocation=/var/spool/slurm:g' \
        -e 's:SlurmdSpoolDir=*.:SlurmdSpoolDir=/var/spool/slurm/slurmd:g' \
        -i "${S}/etc/slurm.conf.example" \
        || die "Can't sed ${S}/etc/slurm.conf.example for StateSaveLocation=*. or SlurmdSpoolDir=*"
    # and tmp should go to /var/tmp/slurm
    sed -e 's:/tmp:/var/tmp:g' \
        -i "${S}/etc/slurm.conf.example" \
        || die "Can't sed for StateSaveLocation=*./tmp"
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
    sed -e "s|htmldir = .*/html|htmldir = \${prefix}/share/doc/slurm-${PVR}/html|g" -i doc/html/Makefile || die
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

    # Install logrotate file
    insinto /etc/logrotate.d
    newins "${FILESDIR}/logrotate" slurm || die

    # cgroups support
    exeinto /etc/slurm/cgroup
    doexe etc/cgroup.release_common.example
    mv ${D}/etc/slurm/cgroup/cgroup.release_common.example ${D}/etc/slurm/cgroup/release_common || die "Can't move cgroup.release_common.example"
    ln -s release_common ${D}/etc/slurm/cgroup/release_cpuset  || die "Can't create symbolic link release_cpuset"
    ln -s release_common ${D}/etc/slurm/cgroup/release_devices || die "Can't create symbolic link release_devices"
    ln -s release_common ${D}/etc/slurm/cgroup/release_freezer || die "Can't create symbolic link release_freezer"
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
            /var/spool/${PN}/slurmd
            /var/spool/${PN}
            /var/run/${PN}
            /var/log/${PN}
            /var/tmp/${PN}/${PN}d
            /var/tmp/${PN})
    for folder_path in ${paths[@]}; do
        create_folders_and_fix_permissions $folder_path
    done
    echo

    elog "Please visit the file '/usr/share/doc/${P}/html/configurator.html"
    elog "through a (javascript enabled) browser to create a configureation file."
    elog "Copy that file to /etc/slurm/slurm.conf on all nodes (including the headnode) of your cluster."
    echo
    elog "For cgroup support, please see http://www.schedmd.com/slurmdocs/cgroup.conf.html"
    elog "Your kernel must be compiled with the wanted cgroup feature:"
    elog "    General setup  --->"
    elog "        [*] Control Group support  --->"
    elog "            [*]   Freezer cgroup subsystem"
    elog "            [*]   Device controller for cgroups"
    elog "            [*]   Cpuset support"
    elog "            [*]   Simple CPU accounting cgroup subsystem"
    elog "            [*]   Resource counters"
    elog "            [*]     Memory Resource Controller for Control Groups"
    elog "            [*]   Group CPU scheduler  --->"
    elog "                [*]   Group scheduling for SCHED_OTHER"
    elog "Then, set these options in /etc/slurm/slurm.conf:"
    elog "    ProctrackType=proctrack/cgroup"
    elog "    TaskPlugin=task/cgroup"
    echo
    ewarn "Paths were created for slurm. Please use these paths in /etc/slurm/slurm.conf:"
    for folder_path in ${paths[@]}; do
    ewarn "    ${folder_path}"
    done
}
