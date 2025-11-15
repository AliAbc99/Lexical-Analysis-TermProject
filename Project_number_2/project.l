digit	[0-9]
letter	[A-Za-z]
%{
  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  #include <iostream>
  using namespace std;
  int linenum=1;
%}
%%

"ADD" {yylval.str=strdup(yytext); return ADD;}
"ADDi" {yylval.str=strdup(yytext); return ADDI;}
"NAND" {yylval.str=strdup(yytext); return NAND;}
"NANDi" {yylval.str=strdup(yytext); return NANDI;}
"SRL" {yylval.str=strdup(yytext); return SRL;}
"SRLi" {yylval.str=strdup(yytext); return SRLI;}
"LT" {yylval.str=strdup(yytext); return LT;}
"LTi" {yylval.str=strdup(yytext); return LTI;}
"CP" {yylval.str=strdup(yytext); return CP;}
"CPi" {yylval.str=strdup(yytext); return CPI;}
"CPI" {yylval.str=strdup(yytext); return CPII;}
"CPIi" {yylval.str=strdup(yytext); return CPIII;}
"BZJ" {yylval.str=strdup(yytext); return BZJ;}
"BZJi" {yylval.str=strdup(yytext); return BZJI;}
"MUL" {yylval.str=strdup(yytext); return MUL;}
"MULi" {yylval.str=strdup(yytext); return MULI;}

{digit}+ {yylval.str=strdup(yytext); return NUM;}

\n {linenum++;}
[ \t]+
.
%%
