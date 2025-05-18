bison -d -v -r all myanalyzer.y
flex myLexer.l
gcc -o mycompiler lex.yy.c myanalyzer.tab.c cgen.c -lfl

./mycompiler < testFiles/test_phase2a.la > testFiles/test_phase2a.c
gcc -std=c99 -Wall testFiles/test_phase2a.c -o testFiles/test_phase2a.out
./testFiles/test_phase2a.out

./mycompiler < testFiles/test_phase2b.la > testFiles/test_phase2b.c
gcc -std=c99 -Wall testFiles/test_phase2b.c -o testFiles/test_phase2b.out
./testFiles/test_phase2b.out

rm -f mycompiler lex.yy.c myanalyzer.tab.c myanalyzer.tab.h myanalyzer.output output.c program 
