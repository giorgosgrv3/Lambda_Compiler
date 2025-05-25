Theory of Computation 2025

CONTENTS OF THE PROJECT:

├── testFiles/
│   ├── lambdalib.h (auxiliary library for Lambda to C, needed to run the files)
│   ├── test_phase1.la (Tests the Flex tool for identifying keywords and identifiers correctly)
│   └── test_phase2a.la , test_phase2a.c (First test for phase 2, along with compiled C file)
│   └── test_phase2b.la , test_phase2b.c (PRIME NUMBERS test for phase 2, along with compiled C file)
    └── qsort.la, qsort.c 
│
├── cgen.c
├── cgen.h
├── myLexer_phase1.l (Flex file for 1st phase)
├── myLexer.l (Flex file for 2nd phase)
├── myanalyzer.y (Bison file)
├── This readme file


!! Each phase has its own Flex file, since in phase 1 we want to specifically see the output of the lexical analysis,
while in phase 2 we simply want to return the token names to Bison, and Bison handles the rest.

FOR PHASE 2:
- The first test, test_phase2a.la, has been created by me, simply to test everything that I have implemented (basic types, variable declaration, assignments, arithmetic, comparisons, Booleans, function definition and calling, main function, returns, if-while-for loops with all the variations such as else, break, continue).
- The second test, test_phase2b.la, is the given Prime numbers file.
They both compile and run in C the way they are intended to.

Updated:
A third file has been added, Quicksort in Lambda, and will run in series after the other 2 files, when running the Phase 2 script.

