
DESCRIPTION="Manages different Intel C/C++ compiler (icc) installations"
HOMEPAGE="http://www.intel.com/software/products/compilers/clin/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# Need skel.bash lib
RDEPEND=">=app-admin/eselect-1.0.5"
DEPEND="${RDEPEND}"

src_install() {
    insinto /usr/share/eselect/modules
    newins "${FILESDIR}/${PN}-${PV}.eselect" icc.eselect || die
    exeinto /etc/profile.d
    doexe "${FILESDIR}/icfc.sh"
    doexe "${FILESDIR}/icfc.csh"
}
