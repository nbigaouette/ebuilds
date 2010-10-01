inherit mpi fortran flag-o-matic

DESCRIPTION="OSU Micro-Benchmarks"
HOMEPAGE="http://mvapich.cse.ohio-state.edu/benchmarks/"
SRC_URI="http://mvapich.cse.ohio-state.edu/benchmarks/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
EAPI=2

#RDEPEND="virtual-mpi"
RDEPEND="mpi-openmpi-intel/openmpi"
DEPEND="${RDEPEND}"

src_configure() {
    #econf $(mpi_econf_args) CC=`which mpicc` || die
    econf $(mpi_econf_args) CC=/usr/lib64/mpi/mpi-openmpi-gcc/usr/bin/mpicc || die
}

src_compile() {
    emake || die
}

src_install() {
    emake DESTDIR="${D}" install || die
}

