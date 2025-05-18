#!/bin/bash
flex myLexer_phase1.l
gcc -o mylexer lex.yy.c -lfl
./mylexer < testFiles/test_phase1.la
rm -f lex.yy.c mylexer
