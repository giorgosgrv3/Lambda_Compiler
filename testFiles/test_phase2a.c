#include "lambdalib.h"

int square(int n) {
return (n * n);
}
int cube(int n) {
return ((n * n) * n);
}
const int taliro = 5;
const StringType randomString = "Lagoudakh akoma perimenw vathmous Texnhth Nohmosynh apo ton Noemvrio\n";
int main() {
writeStr("TEST PRINTING CONSTANT STRING --> ");
writeStr(randomString);
writeStr("TEST PRINTING CONSTANT INTEGER --> ");
writeInteger(taliro);
writeStr("\n");
int a;
int b;
int c;
int theSquare;
int theCube;
a = (taliro * 2);
c = a;
b = 2;
c += b;
c -= 1;
c *= b;
c /= 2;
c %= 3;
theSquare = square(a);
theCube = cube(a);
writeStr("a is ");
writeInteger(a);
writeStr("\n");
writeStr("The square of a is ");
writeInteger(theSquare);
writeStr("\n");
writeStr("The cube of a is ");
writeInteger(theCube);
writeStr("\n");
if ((theSquare < 110)) {
writeStr("The square is smaller than 110. It must reach 110.\n");
while ((theSquare < 110)) {
theSquare += 1;
writeInteger(theSquare);
writeStr("\n");
}
} else {
writeStr("The square is greater than 110.\n");
}
writeStr("\nTESTING WHILE LOOP...(It should do 10, 9, 8, 7, 6)\n");
while ((a > 5)) {
writeInteger(a);
writeStr("\n");
a -= 1;
}
writeStr("\nTESTING FOR LOOP...(It should do 0,1,2)\n");
for (int i = 0; i < 3; ++i) {
writeInteger(i);
writeStr("\n");
}
writeStr("\nTESTING FOR LOOP WITH STEP...(It should do 0,2,4)\n");
for (int i = 0; (i < 5); i += 2) {
writeInteger(i);
writeStr("\n");
}
writeStr("\nTESTING FOR LOOP WITH BREAK...(It should do 0 to 6 and then break)\n");
for (int i = 0; i < 10; ++i) {
writeInteger(i);
writeStr("\n");
if ((i > 5)) {
break;
}
}
writeStr("\nTESTING FOR LOOP WITH CONTINUE... (It should do 0 to 9, but skip 4,5,6,7.)\n");
for (int i = 0; i < 10; ++i) {
if (((((i == 4) || (i == 5)) || (i == 6)) || (i == 7))) {
continue;
}
writeInteger(i);
writeStr("\n");
}
return 0;
}
