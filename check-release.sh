#!/bin/sh

perl Makefile.PL
make
gvimtidy `find lib -name '*.p[lm]'` bin/*
echo "==================== spellcheck ===================="
spellcheck Changes Makefile.PL README `find lib bin t -type f`
echo "==================== TODO ===================="
egrep 'TODO|\?\?\?' `find lib bin t -type f` |
  grep -v 'our \$TODO' |
  grep -v 'local \$TODO' |
  grep -v 'TODO: {' |
  grep -v '".*DC_TODO.*"' |
  grep -v "'.*DC_TODO.*'"
echo "==================== test ===================="
make test

