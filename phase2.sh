bison -d -v -r all myanalyzer.y
flex myLexer.l
gcc -o mycompiler lex.yy.c myanalyzer.tab.c cgen.c -lfl

./mycompiler < testFiles/test_phase2a.la > testFiles/test_phase2a.c
./mycompiler < testFiles/test_phase2b.la > testFiles/test_phase2b.c

rm -f mycompiler lex.yy.c myanalyzer.tab.c myanalyzer.tab.h myanalyzer.output output.c program
