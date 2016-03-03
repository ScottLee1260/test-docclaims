PACKAGE = Test-DocClaims

dist: version
	@echo Building dist for version $(VERSION)
	perl Makefile.PL
	make
	make test
	rm -rf $(PACKAGE)-[0-9]*
	make manifest
	make dist
	@echo ========== TESTING DIST ==========
	make disttest

# Make sure the version numbers match and set the VERSION macro to that number.
# Note that the VERSION macro is dynamically expanded (with = instead of :=)
# because the file will not exist at the time the macro is defined.
VERSION = $(shell cat version)
version: $(VERSION_FILES)
	@if [ `md5sum $(VERSION_FILES) | sed 's/ .*//' | \
	    sort -u | wc -l` = 1 ] ; \
	then \
	    echo versions match ; \
	    sort -u $(VERSION_FILES) > $@ ; \
	    rm -f $(VERSION_FILES) ; \
	    exit 0 ; \
	else \
	    echo ERROR: versions do not match in: $(notdir $(VERSION_FILES)) ; \
	    exit 1 ; \
	fi

# The following rules extract the version number form files that have it. This
# is to make sure that they are updated with each new release and that the
# version numbers match.

VERSION_FILES = version.DocClaims.pm version.Changes version.README

version.DocClaims.pm: lib/Test/DocClaims.pm
	@echo extracting version from $<
	@sed -n \
	    's/.*\$$VERSION\s*=.*\([0-9][0-9]*\.[0-9][0-9.]*\).*/\1/p' \
	    $< > $@

version.Changes: Changes
	@echo extracting version from $<
	@sed -n 's/^\([0-9][0-9]*\.[0-9][0-9.]*\).*/\1/p' $< | tail -1 > $@

version.README: README
	@echo extracting version from $<
	@sed -n '1s/.*\([0-9][0-9]*\.[0-9][0-9.]*\) *$$/\1/p' $< > $@
