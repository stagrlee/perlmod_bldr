# Copyright (C) 2008, Lee Thompson
# Basic MIT license
######################################
#Change History
#  02/15/2008  stagrlee  Original
#  09/10/2008  stagrlee  Open sourced
#
#####################################

EXTRA_DIST = configure_pkg.sh

#dist_pkgdata_DATA=README
dist_bin_SCRIPTS=get_cpan_modules.pl querymods_cpanp.pl querymods_fs.pl

# bash 3.x has a new syntax "<<<" but we want to support bash 2.x
# so this creates an STDIN input file.  So far we just need two
# carraige returns..
get_cpan_STDIN.txt:
	echo "" > get_cpan_STDIN.txt
	echo "" >> get_cpan_STDIN.txt

# Add the CPAN tarballs to the dist after whacking the build directory
# The layout of the cpan web site and the cpanplus cache is alittle 
# different, so there is some file rearranging done
# Note, this runs before the tarball release is created.
dist-hook: get_cpan_STDIN.txt
	set -e; \
	chmod +x *.pl; \
	./get_cpan_modules.pl --net < get_cpan_STDIN.txt; \
	rsync -qr $(srcdir)/cpanplus/authors $(distdir)/cpan/; \
	mkdir $(distdir)/cpan/modules; \
	cp $(srcdir)/cpanplus/01mailrc.txt.gz $(distdir)/cpan/authors/; \
	cp $(srcdir)/cpanplus/02packages.details.txt.gz $(distdir)/cpan/modules/; \
	cp $(srcdir)/cpanplus/03modlist.data.gz $(distdir)/cpan/modules/; \
	cp $(srcdir)/cpanplus/*stored $(distdir)/cpan/

# Add the CPAN tarballs to the install for reference purposes
# Note, this runs after the tarball is unpacked, it uses a local cpan repo
# from the tarball to create a distribution directory. Updates to core
# modules can result in man page conflicts during install.  The pages from
# updated modules that conflict are deleted.  Add to the list as future
# conflicts arise.
install-data-hook: get_cpan_STDIN.txt
	set -e; \
	chmod +x *.pl; \
	./get_cpan_modules.pl < get_cpan_STDIN.txt; \
	rsync -qr $(srcdir)/cpan $(DESTDIR)$(pkgdatadir); \
	find $(DESTDIR)$(pkgdatadir) -name "*tar.gz" |xargs chmod 664; \
	pushd ${PERL_HOME}/share/man; \
	for i in $$(find . -type f -print); do \
	  if test -f $$i && test -e ${DESTDIR}${mandir}/$$i; then \
	    echo "Removing ${DESTDIR}${mandir}/$$i"; \
	    rm -f ${DESTDIR}${mandir}/$$i; \
	  fi; \
	done; \
	popd;

clean:
	-@rm -rf DESTDIR cpanplus get_cpan_STDIN.txt
