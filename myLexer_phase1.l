%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_MACROS 100

typedef struct {
    char* name;
    char* value;
} Macro;

Macro macros[MAX_MACROS];
int macro_count = 0;
int lineno = 1;

void define_macro(const char* name, const char* value) {
	//Save or update a macro name + value
	//e.g. xeirizetai to @defmacro pi 3.14 kanontas macro[0].name = "pi", macro[0].value = "3.14"
    for (int i = 0; i < macro_count; ++i) {
        if (strcmp(macros[i].name, name) == 0) {
            free(macros[i].value);
            macros[i].value = strdup(value);
            return;
        }
    }
    if (macro_count < MAX_MACROS) {
        macros[macro_count].name = strdup(name);
        macros[macro_count].value = strdup(value);
        macro_count++;
    }
}

const char* lookup_macro(const char* name) {
//elegxei an i leksi pou dothike exei apothikeutei ws macro, gia na to kanei substitute
    for (int i = macro_count - 1; i >= 0; --i) {
        if (strcmp(macros[i].name, name) == 0) {
            return macros[i].value;
        }
    }
    return NULL;
}
%}

%option noyywrap

%%

[\n]                        { lineno++; }
[ \t\r]+                   { /* skip whitespace */ }
"--".*                    { /* skip comment */ }

@defmacro[ \t]+([a-zA-Z_][a-zA-Z0-9_]*)[ \t]+(\"(\\.|[^\"])*\"|[^ \t\n\r]+) {
    char* text = strdup(yytext + 10);  // skip "@defmacro"
    char* name = strtok(text, " \t");
    char* value = strtok(NULL, "");

    if (name && value) {
        while (*value == ' ' || *value == '\t') value++; // trim spaces
        define_macro(name, value);
    }

    free(text);
}

"=="                       { printf("token EQ_OP: %s\n", yytext); }
"!="                       { printf("token NEQ_OP: %s\n", yytext); }
"<="                       { printf("token LE_OP: %s\n", yytext); }
">="                       { printf("token GE_OP: %s\n", yytext); }
"<"                        { printf("token LT_OP: %s\n", yytext); }
">"                        { printf("token GT_OP: %s\n", yytext); }

"+"                        { printf("token PLUS_OP: %s\n", yytext); }
"-"                        { printf("token MINUS_OP: %s\n", yytext); }
"*"                        { printf("token MUL_OP: %s\n", yytext); }
"/"                        { printf("token DIV_OP: %s\n", yytext); }
"%"                        { printf("token MOD_OP: %s\n", yytext); }
"**"                       { printf("token POW_OP: %s\n", yytext); }
"="                        { printf("token ASSIGN_OP: %s\n", yytext); }
";"                        { printf("token SEMICOLON: %s\n", yytext); }
":"                        { printf("token COLON: %s\n", yytext); }
","                        { printf("token COMMA: %s\n", yytext); }
"("                        { printf("token LPAREN: %s\n", yytext); }
")"                        { printf("token RPAREN: %s\n", yytext); }
"["                        { printf("token LBRACKET: %s\n", yytext); }
"]"                        { printf("token RBRACKET: %s\n", yytext); }
"."                        { printf("token DOT: %s\n", yytext); }

"True"|"False"             { printf("token CONST_BOOL: %s\n", yytext); }

\"(\\.|[^\"])*\"           { printf("token CONST_STRING: %s\n", yytext); }

[0-9]+\.[0-9]+([eE][-+]?[0-9]+)?   { printf("token CONST_FLOAT: %s\n", yytext); }
[0-9]+                    { printf("token CONST_INT: %s\n", yytext); }

"integer"     { printf("token KEYWORD: %s\n", yytext); }
"scalar"      { printf("token KEYWORD: %s\n", yytext); }
"str"         { printf("token KEYWORD: %s\n", yytext); }
"bool"        { printf("token KEYWORD: %s\n", yytext); }
"const"       { printf("token KEYWORD: %s\n", yytext); }
"if"          { printf("token KEYWORD: %s\n", yytext); }
"else"        { printf("token KEYWORD: %s\n", yytext); }
"endif"       { printf("token KEYWORD: %s\n", yytext); }
"for"         { printf("token KEYWORD: %s\n", yytext); }
"in"          { printf("token KEYWORD: %s\n", yytext); }
"endfor"      { printf("token KEYWORD: %s\n", yytext); }
"while"       { printf("token KEYWORD: %s\n", yytext); }
"endwhile"    { printf("token KEYWORD: %s\n", yytext); }
"break"       { printf("token KEYWORD: %s\n", yytext); }
"continue"    { printf("token KEYWORD: %s\n", yytext); }
"not"         { printf("token KEYWORD: %s\n", yytext); }
"and"         { printf("token KEYWORD: %s\n", yytext); }
"or"          { printf("token KEYWORD: %s\n", yytext); }
"def"         { printf("token KEYWORD: %s\n", yytext); }
"enddef"      { printf("token KEYWORD: %s\n", yytext); }
"main"        { printf("token KEYWORD: %s\n", yytext); }
"return"      { printf("token KEYWORD: %s\n", yytext); }
"comp"        { printf("token KEYWORD: %s\n", yytext); }
"endcomp"     { printf("token KEYWORD: %s\n", yytext); }
"of"          { printf("token KEYWORD: %s\n", yytext); }

[a-zA-Z_][a-zA-Z0-9_]* {
    const char* macro = lookup_macro(yytext);
    if (macro) {
        for (int i = strlen(macro) - 1; i >= 0; --i) {
            unput(macro[i]);
        }
    } else {
        printf("token IDENTIFIER: %s\n", yytext);
    }
}

. {
    printf("Unrecognized token %s in line %d\n", yytext, lineno);
    exit(1);
}
%%

int main() {
    yylex();
    return 0;
}
