digit	[0-9]
letter	[A-Za-z]
%{
  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  #include <iostream>
  using namespace std;
  int tabCounter = 0;
  int linenum=1;
%}
%%

"if" {yylval.str=strdup(yytext); return IF;}
"elif" {yylval.str=strdup("else if"); return ELIF;}
"else" {yylval.str=strdup(yytext); return ELSE;}
":" return COLON;
"=" {yylval.str=strdup(yytext); return EQUAL;}
"=="|"!="|"<"|"<="|">"|">="	{yylval.str=strdup(yytext);  return COMPARISON;}
"*"|"/"|"+"|"-"	{yylval.str=strdup(yytext); return OPERATOR;}
{digit}+(\.){digit}+ {yylval.str=strdup(yytext); return FLOAT;}
{letter}({letter}|{digit})*	{yylval.str=strdup(yytext); return IDENTIFIER;}
{digit}+ {yylval.str=strdup(yytext); return NUM;}
\"[^"]*\"     {yylval.str=strdup(yytext); return STRING;}
\n { return NEWLINE;}
\t {tabCounter++; return TAB;}
.
%%
