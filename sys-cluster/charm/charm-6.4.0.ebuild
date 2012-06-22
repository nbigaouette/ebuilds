# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/charm/charm-6.2.0.ebuild,v 1.2 2012/02/15 19:10:26 jlec Exp $

EAPI=4

inherit eutils flag-o-matic multilib toolchain-funcs

DESCRIPTION="Message-passing parallel language and runtime system"
HOMEPAGE="http://charm.cs.uiuc.edu/"
SRC_URI="http://charm.cs.uiuc.edu/distrib/${P}_src.tar.bz2"

LICENSE="charm"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cmkopt tcp smp doc infiniband"

DEPEND="
	doc? (
	>=app-text/poppler-0.12.3-r3[utils]
	dev-tex/latex2html
	virtual/tex-base )
	infiniband? ( sys-infiniband/libibverbs )"
RDEPEND=""

case ${ARCH} in
	x86)
		CHARM_ARCH="net-linux" ;;

	amd64)
		CHARM_ARCH="net-linux-amd64" ;;
esac

src_prepare() {
	# TCP instead of default UDP for socket comunication
	# protocol
	if use tcp; then
		CHARM_OPTS="${CHARM_OPTS} tcp"
	fi

	# enable direct SMP support using shared memory
	if use smp; then
		CHARM_OPTS="${CHARM_OPTS} smp"
	fi

	# CMK optimization
	if use cmkopt; then
		append-flags -DCMK_OPTIMIZE=1
	fi

	if use infiniband; then
		CHARM_OPTS="${CHARM_OPTS} ibverbs"
	fi

	# Make sure to compile shared libraries
    CHARM_OPTS="${CHARM_OPTS} --build-shared"
    CHARM_OPTS="${CHARM_OPTS} gcc gfortran"

	echo "charm opts: ${CHARM_OPTS}"
}

src_compile() {
	# build charmm++ first
	./build charm++ ${CHARM_ARCH} ${CHARM_OPTS} ${CFLAGS} || \
		die "Failed to build charm++"

	# make pdf/html docs
	if use doc; then
		cd "${S}"/doc
		make doc || die "failed to create pdf/html docs"
	fi
}

src_install() {
	# make charmc play well with gentoo before
	# we move it into /usr/bin
	epatch "${FILESDIR}/charm-6.1.2-charmc-gentoo.patch"

	sed -e "s|gentoo-include|${P}|" \
		-e "s|gentoo-libdir|$(get_libdir)|g" \
		-e "s|VERSION|${P}/VERSION|" \
		-i ./src/scripts/charmc || die "failed patching charmc script"

	# install binaries
	cd "${S}"/bin
	dobin ./charmd ./charmd_faceless ./charmr* ./charmc ./charmxi \
		./conv-cpm ./dep.pl || die "Failed to install binaries"

	# install headers
	cd "${S}"/include
	# EAPI=4 will preserve symbolic links! We need them to be dereferenced.
	#insinto /usr/include/${P}
	#doins * || die "failed to install header files"
	mkdir -p ${D}/usr/include/${P}/
	for header in *; do
        cp --dereference ${header} ${D}/usr/include/${P}/
    done

	# install static libs
	# charm has a lot of .o "libs" that it requires at runtime
	cd "${S}"/lib
	dolib.a *.{a,o} || die "failed to install static libs"

	# install shared libs
	cd "${S}"/lib_so
	dolib.so *.so* || die "failed to install shared libs"

	# basic docs
	cd "${S}"
	dodoc CHANGES README  || die "Failed to install docs"

	# install examples
	find examples/ -name 'Makefile' | xargs sed \
		-r "s:(../)+bin/charmc:/usr/bin/charmc:" -i || \
		die "Failed to fix examples"
	find examples/ -name 'Makefile' | xargs sed \
		-r "s:./charmrun:./charmrun ++local:" -i || \
		die "Failed to fix examples"
	insinto /usr/share/doc/${PF}/examples
	doins -r examples/charm++/*

	# pdf/html docs
	if use doc; then
		cd "${S}"/doc
		# install pdfs
		insinto /usr/share/doc/${PF}/pdf
		doins  doc/pdf/* || die "failed to install pdf docs"
		# install html
		docinto html
		dohtml -r doc/html/* || die "failed to install html docs"
	fi
}

pkg_postinst() {
	echo
	einfo "Please test your charm installation by copying the"
	einfo "content of /usr/share/doc/${PF}/examples to a"
	einfo "temporary location, uncompress files and compile:"
	einfo "    cp -r /usr/share/doc/${PF}/examples /tmp/"
    einfo "    cd /tmp/examples"
	einfo "    find . -name \"*.bz2\" -exec bzip2 -d {} \;"
	einfo "    make test"
	echo
}
