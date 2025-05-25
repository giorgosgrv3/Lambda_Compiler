#!/bin/bash

flex myLexer_phase1.l
gcc -o mylexer lex.yy.c -lfl

./mylexer < testFiles/test_phase1.la > testFiles/test_phase1.tokens

cat testFiles/test_phase1.tokens

rm -f mylexer lex.yy.c
rm -f testFiles/test_phase1.tokens
