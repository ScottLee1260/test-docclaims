#!/bin/sh

perl Makefile.PL
make
gvimtidy `find lib bin t -name '*.p[lm]'`
echo "==================== spellcheck ===================="
spellcheck Changes Makefile.PL README `find lib bin t -type f`
echo "==================== debug ===================="
egrep '\?\?\?' `find lib bin t -type f`
echo "==================== TODO ===================="
egrep 'TODO' `find lib bin t -type f` |
  grep -v '\$TODO' |
  grep -v 'TODO: *{' |
  grep -v '^[^ ]*:[^=].*DC_TODO'
echo "==================== test ===================="
make test

