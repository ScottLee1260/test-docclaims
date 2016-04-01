# The name of the package with "-" in place of "::" and the path of the source
# file that contains the version number.
PACKAGE = Test-DocClaims
VERSION_SRC = lib/Test/DocClaims.pm

VERSION = $(shell cat version)
dist: version
	@echo Building dist for version $(VERSION)
	perl Makefile.PL
	make
	make test
	rm -rf $(PACKAGE)-[0-9]*
	rm -f MANIFEST
	[ -f Templ.MANIFEST.SKIP ] && cp Templ.MANIFEST.SKIP MANIFEST.SKIP
	make manifest
	make dist
	@echo ========== TESTING DIST ==========
	make disttest

# Make sure the version numbers match and set the VERSION macro to that number.
# Note that the VERSION macro is dynamically expanded (with = instead of :=)
# because the file will not exist at the time the macro is defined.
VERSION_FILES = version.source.pm version.Changes version.README
version: $(VERSION_FILES)
	@if md5sum $(VERSION_FILES) | sed 's/ .*//' | \
	    sort | uniq -c | grep '^ *3 ' ; \
	then \
	    echo versions match ; \
	    sort -u $(VERSION_FILES) > $@ ; \
	    rm -f $(VERSION_FILES) ; \
	    exit 0 ; \
	else \
	    echo ERROR: versions do not match in: $(VERSION_FILES) ; \
	    exit 1 ; \
	fi

# The following rules extract the version number form files that have it. This
# is to make sure that they are updated with each new release and that the
# version numbers match.

version.source.pm: $(VERSION_SRC)
	@echo extracting version from $<
	@sed -n \
	    's/.*\$$VERSION\s*=.*\([0-9][0-9]*\.[0-9][0-9.]*\).*/\1/p' \
	    $< > $@.tmp
	@mv $@.tmp $@

version.Changes: Changes
	@echo extracting version from $<
	@sed -n 's/^\([0-9][0-9]*\.[0-9][0-9.]*\).*/\1/p' $< | tail -1 > $@.tmp
	@mv $@.tmp $@

version.README: README
	@echo extracting version from $<
	@sed -n '1s/.*\([0-9][0-9]*\.[0-9][0-9.]*\) *$$/\1/p' $< > $@.tmp
	@mv $@.tmp $@

clean:
	rm -f version version.*
	rm -rf $(PACKAGE)-[0-9]*
	rm -f MANIFEST*
	make realclean
