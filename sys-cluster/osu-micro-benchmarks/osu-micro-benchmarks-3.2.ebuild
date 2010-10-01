DESCRIPTION="OSU Micro-Benchmarks"
HOMEPAGE="http://mvapich.cse.ohio-state.edu/benchmarks/"
SRC_URI="http://mvapich.cse.ohio-state.edu/benchmarks/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
EAPI="2"

RDEPEND="virtual-mpi"
DEPEND="${RDEPEND}"

src_configure() {
    econf || die
}

src_compile() {
    emake || die
}

src_install() {
    emake DESTDIR="${D}" install || die
}

