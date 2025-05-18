%{
/* myLexer.l --> KANOUME DEFINE TA TOKENS THS LAMBDA */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cgen.h"
#include "myanalyzer.tab.h"

int line_num = 1;
%}

%option noyywrap

%%

[\n]  		{ line_num++; }
[ \t\r]+  	{ }
"--".*    	{ }

"**"        { return KW_POW; }
"=="        { return KW_EQ; }
"!="        { return KW_NOTEQ; }
"<="        { return KW_LESSEQ; }
">="        { return KW_GREATEREQ; }
":="        { return KW_COLONEQ; }
"+="        { return KW_INCR; }
"-="        { return KW_DECR; }
"*="        { return KW_TIMES_INCR; }
"/="        { return KW_DIV_DECR; }
"%="        { return KW_MOD_DECR; }
"->"        { return KW_RETURN_ARROW; }

"<"         { return '<'; }
">"         { return '>'; }
"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
"%"         { return '%'; }
"="         { return '='; }
";"         { return ';'; }
":"         { return ':'; }
","         { return ','; }
"("         { return '('; }
")"         { return ')'; }
"["         { return '['; }
"]"         { return ']'; }
"."         { return '.'; }
"!"         { return '!'; }
"#"         { return '#'; }

"True"      { yylval.str = strdup("1"); return KW_TRUE; }
"False"     { yylval.str = strdup("0"); return KW_FALSE; }

\"(\\\\.|[^\"])*\" {
    yylval.str = strdup(yytext);
    return TK_STRING;
}

[0-9]+\.[0-9]+([eE][-+]?[0-9]+)? {
    yylval.str = strdup(yytext);
    return TK_REAL;
}

[0-9]+ {
    yylval.str = strdup(yytext);
    return TK_NUMBER;
}

"integer"   { return KW_INT; }
"scalar"    { return KW_SCALAR; }
"str"       { return KW_STRING; }
"bool"      { return KW_BOOLEAN; }
"const"     { return KW_CONST; }
"if"        { return KW_IF; }
"else"      { return KW_ELSE; }
"endif"     { return KW_ENDIF; }
"for"       { return KW_FOR; }
"in"        { return KW_IN; }
"endfor"    { return KW_ENDFOR; }
"while"     { return KW_WHILE; }
"endwhile"  { return KW_ENDWHILE; }
"break"     { return KW_BREAK; }
"continue"  { return KW_CONTINUE; }
"not"       { return KW_NOT; }
"and"       { return KW_AND; }
"or"        { return KW_OR; }
"def"       { return KW_DEF; }
"enddef"    { return KW_ENDDEF; }
"main"      { return KW_MAIN; }
"return"    { return KW_RETURN; }
"comp"      { return KW_COMP; }
"endcomp"   { return KW_ENDCOMP; }
"of"        { return KW_OF; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return IDENTIFIER;
}

. {
    fprintf(stderr, "Unrecognized token %s in line %d\n", yytext, line_num);
    exit(1);
}
%%
