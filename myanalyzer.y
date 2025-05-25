%{
/* myanalyzer.y --> KANOUME DEFINE GRAMMAR RULES APO TA TOKENS STO myLexer.l*/

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cgen.h"

sstream code;			// buffer pou mazevei ton paragomeno C code
extern int line_num;			// obvious, gia to error msg pou anaferei line number of error
int yylex(void);			/*called by yyparse(), pou einai automatically generated apo to Bison otan to .y file ginetai compile,
							dhladh o yyparse() kalei ton yylex() internally gia na mazepsei o yylex() tokens, kai na ta epistrepsei ston yyparse().
							Epeita o yyparse() xrhsimopoiei ta tokens pou eginan return apo yylex() gia na kanei match grammar rules.*/
%}

%union {		/* Data structure pou mporei na krataei ena data type ana fora*/
    char* str;			/* Use char* gia ta perissotera apla values (strings, identifiers, arithmous, expressions) */
    char** strlist;			/* Use char** (pointer se array) gia representation twn lists apo identifiers, p.x. x,y,z : integer; */
}

%token <str> IDENTIFIER				/* Ara ena identifier (opoiodhpote kai an einai), einai typou char*   */
%token <str> TK_NUMBER TK_REAL TK_STRING		/* Otan o lexer epistrefei p.x. TK_STRING, kanei yylval.str = strdup ("said string") */

/* Osa DEN exoun typo char* (str) or char** (strlist), einai reserved keywords, opws edw: */
%token KW_INT KW_SCALAR KW_STRING KW_BOOLEAN
%token KW_TRUE KW_FALSE
%token KW_DEF KW_ENDDEF KW_MAIN KW_RETURN
%token KW_IF KW_ELSE KW_ENDIF
%token KW_FOR KW_IN KW_ENDFOR
%token KW_WHILE KW_ENDWHILE
%token KW_BREAK KW_CONTINUE
%token KW_CONST KW_COMP KW_ENDCOMP KW_OF
%token KW_POW KW_EQ KW_NOTEQ KW_LESSEQ KW_GREATEREQ
%token KW_COLONEQ KW_INCR KW_DECR KW_TIMES_INCR KW_DIV_DECR KW_MOD_DECR
%token KW_NOT KW_AND KW_OR
%token KW_RETURN_ARROW


/* Priority twn telestwn, aristera -> deksia or deksia -> aristera */

%left KW_OR
%left KW_AND
%right KW_NOT
%left KW_EQ KW_NOTEQ
%left '<' '>' KW_LESSEQ KW_GREATEREQ
%left '+' '-'
%left '*' '/' '%'
%right KW_POW
%right UMINUS

/* Typoi apo non-terminals --> intermediate building blocks, otidhpote allo uparxei mesa sth glwssa. */

%type <str> variable_type		/* integer, scalar, klp klp. Einai mia leksh (integer, klp), opote einai char* typos*/
%type <strlist> identifiers_list		/* Kanei parse mia lista apo identifiers, p.x. x,y,z : integer; --> Ara einai typou char**   */
%type <str> const_value		/* Gia tis statheres mas*/
%type <str> expression			/* Ena expression, otidhpote, arithmetic, logical, comparison, klp. p.x. a + b - c */
%type <str> parameters_list_opt parameters_list return_type_opt		/* parameters_list --> lista parameters, a: integer, b: integer, klp,
																	return_type_opt --> to proairetiko return type tou kathe function */
%type <str> statement_list statement declaration_in_func		/*statement_list -> 0 h parapanw statements, statement -> if, while, klp.,
																	declaration_in_func -> variable declarations mesa se function bodies */			
%type <str> arg_list_opt arg_list 		/* arg_list --> arguments se ena function,
										arg_list_optional --> to idio, alla mporei kai na einai adeio*/



%%		/* Pame na ksekinhsoume me grammar rules twra*/

starting: 		// edw ksekinaei h grammatikh 
    gather_declarations
    {
        printf("%s", c_prologue);		/* vazoume to lambdalib sthn arxh tou C arxeiou */
        printf("%s", ssvalue(&code));		/* olos o upoloipos produced C code apo to parsing*/
    }
    ;

gather_declarations:		/* mazevei recursively ta TOP-LEVEL variable declarations/statements , osa kai an einai*/
    gather_declarations one_declaration
    | one_declaration
    ;				/* auto simainei : gia kathe declaration, mazevoume auto (statement) h kai ta epomena tou (gather_statements)*/

one_declaration: 	/* OPOIODHPOTE declaration/statement */

    identifiers_list ':' variable_type ';'	// x,y,z : integer;
    {
        for (int i = 0; $1[i] != NULL; i++) {
            char *decl = template("%s %s;\n", $3, $1[i]);
            fputs(decl, code.stream);
            free($1[i]);
            free(decl);
        }
        free($1);
        free($3);
    }
    | IDENTIFIER '[' TK_NUMBER ']' ':' variable_type ';'
    {
        char *decl = template("%s %s[%s];\n", $6, $1, $3);
        fputs(decl, code.stream);
        free($1); free($3); free($6); free(decl);
    }
    | KW_CONST IDENTIFIER '=' const_value ':' variable_type ';'		/* const pi = 3.14 : scalar; */
    {
        char *decl = template("const %s %s = %s;\n", $6, $2, $4);
        fputs(decl, code.stream);
        free($2);
        free($4);
        free($6);
    }
    | IDENTIFIER '=' expression ';'		/* assignments --> e.g. x = y + 3;  */
    {
        char *stmt = template("%s = %s;\n", $1, $3);
        fputs(stmt, code.stream);
        free($1);
        free($3);
    }
    | KW_DEF KW_MAIN '(' ')' ':' statement_list KW_ENDDEF ';'	/* int main(): .. polla statements .. telos main */
    {
        fputs("int main() {\n", code.stream);
        fputs($6, code.stream);
        fputs("return 0;\n}\n", code.stream);
        free($6);
    }
    | KW_DEF IDENTIFIER '(' parameters_list_opt ')' return_type_opt ':' statement_list KW_ENDDEF ';'		/* function definition
																									def add (x:integer, y:integer) -> integer: .... enddef */
    {
        char *header = template("%s %s(%s) {\n", $6 ? $6 : "void", $2, $4 ? $4 : "");
        fputs(header, code.stream);
        fputs($8, code.stream);
        fputs("}\n", code.stream);
        free($2); if ($4) free($4); if ($6) free($6); free($8); free(header);
    }
    ;

declaration_in_func:		/* MONO gia mesa se functions, gia topikes metavlhtes mesa se main h alla functions */
    identifiers_list ':' variable_type ';'		/* x : integer; */
    {
        sstream S;
        ssopen(&S);
        for (int i = 0; $1[i] != NULL; i++) {
            char *decl = template("%s %s;\n", $3, $1[i]);
            fputs(decl, S.stream);
            free($1[i]);
        }
        free($1);
        free($3);
        $$ = ssvalue(&S);
        ssclose(&S);
    }
    ;

identifiers_list:	/* to list apo identifiers tha einai eite .. */
    IDENTIFIER		/* ENAS identifier .. */
    {
        char** ids = malloc(2 * sizeof(char*));
        ids[0] = $1;
        ids[1] = NULL;
        $$ = ids;
    }
    | identifiers_list ',' IDENTIFIER	/* eite POLLOI identifiers */
    {
        int count = 0;
        while ($1[count] != NULL) count++;
        char** ids = realloc($1, (count + 2) * sizeof(char*));
        ids[count] = $3;
        ids[count + 1] = NULL;
        $$ = ids;
    }
    ;

const_value:		/* ena constant/stathera mporei na einai enas arithmos, enas pragmatikos arithmos, ena string, true/false */
    TK_NUMBER  { $$ = strdup($1); }
    | TK_REAL    { $$ = strdup($1); }
    | TK_STRING  { $$ = strdup($1); }
    | KW_TRUE    { $$ = strdup("1"); }
    | KW_FALSE   { $$ = strdup("0"); }
    ;

expression:		/* ola ta possible combinations apo expressions, gia arithmetic, logical, relational sugkriseis*/

    expression '+' expression    { $$ = template("(%s + %s)", $1, $3); free($1); free($3); }
    | expression '-' expression    { $$ = template("(%s - %s)", $1, $3); free($1); free($3); }
    | expression '*' expression    { $$ = template("(%s * %s)", $1, $3); free($1); free($3); }
    | expression '/' expression    { $$ = template("(%s / %s)", $1, $3); free($1); free($3); }
    | expression '%' expression    { $$ = template("(%s %% %s)", $1, $3); free($1); free($3); }
    | expression KW_POW expression { $$ = template("pow(%s, %s)", $1, $3); free($1); free($3); }
    | expression KW_EQ expression  { $$ = template("(%s == %s)", $1, $3); free($1); free($3); }
    | expression KW_NOTEQ expression { $$ = template("(%s != %s)", $1, $3); free($1); free($3); }
    | expression '<' expression    { $$ = template("(%s < %s)", $1, $3); free($1); free($3); }
    | expression '>' expression    { $$ = template("(%s > %s)", $1, $3); free($1); free($3); }
    | expression KW_LESSEQ expression { $$ = template("(%s <= %s)", $1, $3); free($1); free($3); }
    | expression KW_GREATEREQ expression { $$ = template("(%s >= %s)", $1, $3); free($1); free($3); }
    | expression KW_AND expression { $$ = template("(%s && %s)", $1, $3); free($1); free($3); }
    | expression KW_OR expression  { $$ = template("(%s || %s)", $1, $3); free($1); free($3); }
    | KW_NOT expression      { $$ = template("(!%s)", $2); free($2); }
    | '-' expression %prec UMINUS { $$ = template("(-%s)", $2); free($2); }
    | '+' expression %prec UMINUS { $$ = template("(+%s)", $2); free($2); }
    | IDENTIFIER '(' arg_list_opt ')' { $$ = template("%s(%s)", $1, $3 ? $3 : ""); free($1); if ($3) free($3); }
    | '(' expression ')'     { $$ = $2; }
    | IDENTIFIER       { $$ = strdup($1); }
    | TK_NUMBER        { $$ = strdup($1); }
    | TK_REAL          { $$ = strdup($1); }
    | TK_STRING        { $$ = strdup($1); }
    | KW_TRUE          { $$ = strdup("1"); }
    | KW_FALSE         { $$ = strdup("0"); }
    | IDENTIFIER '[' expression ']' {
        $$ = template("%s[%s]", $1, $3);
        free($1); free($3);
    }
    ;

variable_type:		/* oi diathesimoi typoi variables */
    KW_INT     { $$ = strdup("int"); }
    | KW_SCALAR  { $$ = strdup("double"); }
    | KW_STRING  { $$ = strdup("StringType"); }
    | KW_BOOLEAN { $$ = strdup("int"); }
    ;

parameters_list_opt:	/* parameters se functions mporei na uparxoun (def function (x:integer)), h kai oxi (def function() ) */
    /* empty */ { $$ = NULL; }
    | parameters_list { $$ = $1; }		/* an den einai adeio, edw kalei to parameter list apo katw gia na parei ta parameters */
    ;

parameters_list:
    IDENTIFIER ':' variable_type {
        $$ = template("%s %s", $3, $1); free($1); free($3);
    }
    | IDENTIFIER '[' ']' ':' variable_type {
        // e.g. param[]: integer → int* param
        $$ = template("%s* %s", $5, $1); free($1); free($5);
    }
    | parameters_list ',' IDENTIFIER ':' variable_type {
        char *param = template("%s %s", $5, $3);
        $$ = template("%s, %s", $1, param);
        free($1); free($3); free($5); free(param);
    }
    | parameters_list ',' IDENTIFIER '[' ']' ':' variable_type {
        // e.g. ... , param[]: integer
        char *param = template("%s* %s", $7, $3);
        $$ = template("%s, %s", $1, param);
        free($1); free($3); free($7); free(param);
    }
;

return_type_opt:		/* return type episis mporei na ginei skip */
    /* empty */ { $$ = NULL; }
    | KW_RETURN_ARROW variable_type { $$ = $2; }
    ;

statement_list:		/* statements mporei na mhn uparxoun*/
    statement_list statement {
        $$ = template("%s%s", $1, $2); free($1); free($2);
    }
    | /* empty */ { $$ = strdup(""); }
    ;

statement:		/* OPOIODHPOTE legal Lambda statement */

    IDENTIFIER '=' expression ';' {     /* e.g. x = 3; */
        $$ = template("%s = %s;\n", $1, $3); free($1); free($3);
    }
    | IDENTIFIER '(' arg_list_opt ')' ';' {     /* e.g. writeInt(x); */
        $$ = template("%s(%s);\n", $1, $3 ? $3 : ""); free($1); if ($3) free($3);
    }
	| IDENTIFIER KW_INCR expression ';' {
    $$ = template("%s += %s;\n", $1, $3); free($1); free($3);
	}
	| IDENTIFIER KW_DECR expression ';' {
		$$ = template("%s -= %s;\n", $1, $3); free($1); free($3);
	}
	| IDENTIFIER KW_TIMES_INCR expression ';' {
		$$ = template("%s *= %s;\n", $1, $3); free($1); free($3);
	}
	| IDENTIFIER KW_DIV_DECR expression ';' {
		$$ = template("%s /= %s;\n", $1, $3); free($1); free($3);
	}
	| IDENTIFIER KW_MOD_DECR expression ';' {
		$$ = template("%s %%= %s;\n", $1, $3); free($1); free($3);
	}

    | KW_RETURN expression ';' {
        $$ = template("return %s;\n", $2); free($2);
    }
    | KW_RETURN ';' {
        $$ = strdup("return;\n");
    }
    | KW_IF '(' expression ')' ':' statement_list KW_ENDIF ';' {
        $$ = template("if (%s) {\n%s}\n", $3, $6); free($3); free($6);
    }
    | KW_IF '(' expression ')' ':' statement_list KW_ELSE ':' statement_list KW_ENDIF ';' {
        $$ = template("if (%s) {\n%s} else {\n%s}\n", $3, $6, $9); free($3); free($6); free($9);
    }
	| KW_FOR IDENTIFIER KW_IN '[' expression ':' expression ']' ':' statement_list KW_ENDFOR ';'
    {
        $$ = template("for (int %s = %s; %s < %s; ++%s) {\n%s}\n",
                       $2, $5, $2, $7, $2, $10);
        free($2); free($5); free($7); free($10);
    }
    | KW_FOR IDENTIFIER KW_IN '[' expression ':' expression ':' expression ']' ':' statement_list KW_ENDFOR ';'
    {
        $$ = template("for (int %s = %s; (%s < %s); %s += %s) {\n%s}\n",
                       $2, $5, $2, $7, $2, $9, $12);
        free($2); free($5); free($7); free($9); free($12);
    }
	| KW_WHILE '(' expression ')' ':' statement_list KW_ENDWHILE ';'
	{
    $$ = template("while (%s) {\n%s}\n", $3, $6);
    free($3); free($6);
	}
    | KW_FOR IDENTIFIER KW_IN IDENTIFIER KW_OF TK_NUMBER ':' statement_list KW_ENDFOR ';'
    {
        $$ = template("for (int %s_i = 0; %s_i < %s; ++%s_i) {\n%s %s = %s[%s_i];\n%s}\n",
                       $4, $4, $6, $4,
                       "auto", $2, $4, $4, $8);
        free($2); free($4); free($6); free($8);
    }
	| KW_BREAK ';' {
    $$ = strdup("break;\n");
	}
	| KW_CONTINUE ';' {
		$$ = strdup("continue;\n");
	}
    | declaration_in_func { $$ = $1; }

    /* ARRAYS */
    | IDENTIFIER '[' expression ']' '=' expression ';'
    {
        $$ = template("%s[%s] = %s;\n", $1, $3, $6);
        free($1); free($3); free($6);
    }
    | IDENTIFIER '[' expression ']' KW_INCR expression ';' {
    $$ = template("%s[%s] += %s;\n", $1, $3, $6); free($1); free($3); free($6);
	}
    | IDENTIFIER '[' expression ']' KW_DECR expression ';' {
    $$ = template("%s[%s] -= %s;\n", $1, $3, $6); free($1); free($3); free($6);
	}
    | IDENTIFIER '[' expression ']' KW_TIMES_INCR expression ';' {
    $$ = template("%s[%s] *= %s;\n", $1, $3, $6); free($1); free($3); free($6);
	}
    | IDENTIFIER '[' expression ']' KW_DIV_DECR expression ';' {
    $$ = template("%s[%s] /= %s;\n", $1, $3, $6); free($1); free($3); free($6);
	}
    | IDENTIFIER '[' expression ']' KW_MOD_DECR expression ';' {
    $$ = template("%s[%s] %%= %s;\n", $1, $3, $6); free($1); free($3); free($6);
	}

    /* COMPACT ARRAYS FROM INTEGERS */
    | IDENTIFIER KW_COLONEQ '[' expression KW_FOR IDENTIFIER ':' expression ']' ':' variable_type ';'
    {
        // malloc line: new_type* new_array = (new_type*)malloc(size * sizeof(new_type));
        char* malloc_stmt = template("%s* %s = (%s*)malloc(%s * sizeof(%s));\n",
                                    $11, $1, $11, $8, $11);
        
        // for-loop:
        char* for_loop = template("for (int %s = 0; %s < %s; ++%s) {\n  %s[%s] = %s;\n}\n",
                                $6, $6, $8, $6, $1, $6, $4);

        // combine both
        $$ = template("%s%s", malloc_stmt, for_loop);

        free($1); free($4); free($6); free($8); free($11);
        free(malloc_stmt); free(for_loop);
    }

    /* COMPACT ARRAYS FROM OTHER ARRAYS */
    | IDENTIFIER KW_COLONEQ '[' expression KW_FOR IDENTIFIER ':' variable_type KW_IN IDENTIFIER KW_OF expression ']' ':' variable_type ';'
    {
        // malloc line for the new_array
        char* malloc_stmt = template("%s* %s = (%s*)malloc(%s * sizeof(%s));\n",
                                    $15, $1, $15, $12, $15);

        // for-loop:
        char* for_loop = template("for (int %s_i = 0; %s_i < %s; ++%s_i) {\n"
                                "  %s %s = %s[%s_i];\n"
                                "  %s[%s_i] = %s;\n}\n",
                                $10, $10, $12, $10,      // index usage
                                $8, $6, $10, $10,        // element declaration
                                $1, $10, $4);            // final assignment

        // combine malloc and for-loop
        $$ = template("%s%s", malloc_stmt, for_loop);

        // free memory
        free($1); free($4); free($6); free($8); free($10); free($12); free($15);
        free(malloc_stmt); free(for_loop);
    }

    ;

arg_list_opt:		/* Se function call, mporei kai na mhn uparxoun orismata (an profanws to parameter_list_opt pou eipame panw einai keno)*/
    /* empty */ { $$ = NULL; }
    | arg_list { $$ = $1; }
    ;

arg_list:
    expression { $$ = $1; }
    | arg_list ',' expression {
        $$ = template("%s, %s", $1, $3); free($1); free($3);
    }
    ;

%%

int main(void) {
    ssopen(&code);	/* anoigei buffer, xrhsimopoiei kwdika apo to cgen.c, olos o generated C code paei sto code.stream (sstream code)*/
    int result = yyparse();		 /*eipame panw oti kalei yylex() */
    ssclose(&code);			/* kleinei buffer */
    return result;		/* 0 success, !=0 syntax error */
}
