#!/bin/bash

# 2.sh - Complete build + test + full cleanup for Phase 2

bison -d myanalyzer.y
flex mylexer.l
gcc -o mycompiler lex.yy.c myanalyzer.tab.c cgen.c -lfl -lm

# Run tests
./mycompiler < testFiles/test_phase2a.la > testFiles/test_phase2a.c
gcc -o testFiles/test_phase2a.out testFiles/test_phase2a.c -lm
./testFiles/test_phase2a.out

./mycompiler < testFiles/test_phase2b.la > testFiles/test_phase2b.c
gcc -o testFiles/test_phase2b.out testFiles/test_phase2b.c -lm
./testFiles/test_phase2b.out

./mycompiler < testFiles/qsort.la > testFiles/qsort.c
gcc -o testFiles/qsort.out testFiles/qsort.c -lm
./testFiles/qsort.out

# Full cleanup
rm -f mycompiler lex.yy.c myanalyzer.tab.c myanalyzer.tab.h myanalyzer.output
rm -f testFiles/test_phase2a.c testFiles/test_phase2b.c testFiles/qsort.c
rm -f testFiles/test_phase2a.out testFiles/test_phase2b.out testFiles/qsort.out

