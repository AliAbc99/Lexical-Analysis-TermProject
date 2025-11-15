%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <string.h>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);

	extern int linenum;// use variable linenum from the lex file


%}

%union
{
	int number;
	char * str;
}

%token <str>  NUM ADD ADDI NAND NANDI SRL SRLI LT LTI CP CPI CPII CPIII BZJ BZJI MUL MULI  
%left NUM
%%

program:
		line
		|
		line program
;
line:
        ADD NUM NUM{
			string a = $2;
			string b = $3;
			cout<< "MEM["<<a<<"] = MEM["<<a<<"] + MEM["<<b<<"]"<<endl;
		}
		|
		ADDI NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM["<<a<<"] = MEM["<<a<<"] + "<<b<<endl;
		}
		|
		NAND NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM["<<a<<"] = ~(MEM["<<a<<"] & MEM["<<b<<"])"<<endl;			
		}
		|
		NANDI NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM["<<a<<"] = ~(MEM["<<a<<"] & "<<b<<")"<<endl;
		}
		|
		SRL NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"IF (MEM["<<b<<"] < 32) THEN \n\tMEM["<<a<<"] = MEM["<<a<<"] >> MEM["<<b<<"] \nELSE \n\tMEM["<<a<<"] = MEM["<<a<<"] << (MEM["<<b<<"] - 32) \nENDIF"<<endl;
		}
		|
		SRLI NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM["<<a<<"] = MEM["<<a<<"] >> "<<b<<endl;
		}
		|
		LT NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM["<<a<<"] = MEM["<<a<<"] < MEM["<<b<<"]"<<endl;
		}
		|
		LTI NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM["<<a<<"] = MEM["<<a<<"] < "<<b<<endl;
		}
		|
		CP NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM["<<a<<"] = MEM["<<b<<"]"<<endl;
		}
		|
		CPI NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM["<<a<<"] = "<<b<<endl;
		}
		|
		CPII NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM["<<a<<"] = MEM[MEM["<<b<<"]]"<<endl;
		}
		|
		CPIII NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM[MEM["<<a<<"]] = MEM["<<b<<"]"<<endl;
		}
		|
		BZJ NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"IF (MEM["<<b<<"] == 0) THEN\n\tPC = MEM["<<a<<"]\nELSE\n\tPC = PC+1\nENDIF"<<endl;
		}
		|
		BZJI NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"PC = MEM["<<a<<"] + "<<b<<endl;
		}
		|
		MUL NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM["<<a<<"] = MEM["<<a<<"] * MEM["<<b<<"]"<<endl;
			
		}
		|
		MULI NUM NUM{
			string a = $2;
			string b = $3;
			cout<<"MEM["<<a<<"] = MEM["<<a<<"] * "<<b<<endl;
		}
;


%%


void yyerror(string s){
	cerr<<"Error at line: "<<linenum<<endl;
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
    return 0;
}
