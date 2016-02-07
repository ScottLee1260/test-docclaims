help:
	@echo targets: dist clean

dist:
	rm -rf src/Test-DocClaims
	./make_release.pl
	mv src/Test-DocClaims-*.tar.gz .

clean:
	cd src && make realclean
	rm -f  src/Test-DocClaims-*.tar*
	rm -rf src/Test-DocClaims
	rm -f  src/README src/MANIFEST*
