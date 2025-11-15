%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <vector>
	#include <map>
	#include <string.h>
	#include <algorithm>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);

	extern int linenum;// use variable linenum from the lex file
	extern int tabCounter; // use variable tabCounter from the lex file

	vector <string> typeVec;
	vector <string> lineStrings;
  	
	struct ifelifelse{
        bool closed;
		int tabCount;
		string type;
    };
	vector <ifelifelse> ifVector;

	struct Variable{
        string name;
		string type;
    };
    vector <Variable> variableVector;
	
	int expectedTabCounter = 0;

%}

%union
{
	char * str;
}

%token <str> IF ELIF ELSE COLON EQUAL COMPARISON OPERATOR FLOAT IDENTIFIER NUM STRING NEWLINE TAB
%type<str> assignment operand if elseif else line program ifstatement
%left OPERATOR COMPARISON
%%


program:
		line
		{

			cout << "void main()"<< endl;
			cout << "{"<< "\n" ;

			for (int i = 0; i < variableVector.size(); i++) 
			{			    
			    for (int j = i + 1;j < variableVector.size();j++) 
			    {
			        if (variableVector[i].name == variableVector[j].name && variableVector[i].type == variableVector[j].type) 
			        {
			            variableVector.erase(variableVector.begin() + j);
						j--;
			        }			        
			    }
			    
			}
			vector<string> stringVrbls;	//string variables
			vector<string> intigers;
			vector<string> floatNums;
			for(int i=0; i<variableVector.size(); i++)
			{
				if(variableVector[i].type == "int")
				{
					string temp = variableVector[i].name + "_" + variableVector[i].type;
					intigers.push_back(temp);
				}

				if(variableVector[i].type == "flt")
				{
					string temp = variableVector[i].name + "_" + variableVector[i].type;
					floatNums.push_back(temp);
				}

				if(variableVector[i].type == "str")
				{
					string temp = variableVector[i].name + "_" + variableVector[i].type;
					stringVrbls.push_back(temp);
				}
			}
			if(!intigers.empty())
			{
				cout<<"\t" << "int ";  
				for(int i=0; i<intigers.size()-1; i++)
				{
			       	cout << intigers[i] << ",";			       
				}
				cout << intigers[intigers.size()-1] << ";" <<endl  ;
			}
			if(!floatNums.empty())
			{
				cout<<"\t" << "float ";  
				for(int i=0; i<floatNums.size()-1; i++)
				{
			       	cout << floatNums[i] << ",";			       
				}
				cout << floatNums[floatNums.size()-1] << ";" <<endl  ;
			}
			if(!stringVrbls.empty())
			{
				cout<< "\t" << "string ";  
				for(int i=0; i<stringVrbls.size()-1; i++)
				{
			       	cout << stringVrbls[i] << ",";			       
				}
				cout << stringVrbls[stringVrbls.size()-1] << ";" <<endl  ;
			}
			cout << endl << "\t";

			vector<string> tabbed_strings;
		  	for (const string& s : lineStrings) 
		  	{
		    	string tabbed_string = s;
		    	size_t pos = 0;
		    	while ((pos = tabbed_string.find("\n", pos)) != string::npos) 
		    	{
		      		tabbed_string.replace(pos, 1, "\n\t");
		      		pos += 1;
		    	}
		    	tabbed_strings.push_back(tabbed_string);
		  	}			

			vector<string> delete_t;
			if(!ifVector.empty() )
			{
				for(int i = ifVector.size()-1; i>=0; i--)
				{
					string combined = "";
					if(ifVector[i].closed == false)
					{
						for(int j = ifVector[i].tabCount; j>0; j--)
						{
							combined+= "\t";
						}
						combined+= "}\n\t";
						delete_t.push_back(combined);
						ifVector[i].closed = true;
					}
				}
			}
			if(delete_t.empty()==false)
			{
				delete_t.back().erase(remove(delete_t.back().begin(), delete_t.back().end(), '\t'), delete_t.back().end());
				
				for(int i = 0; i<tabbed_strings.size(); i++)
				{
					cout << tabbed_strings[i];
				}
				for(int i = 0; i<delete_t.size(); i++)
				{
					cout << delete_t[i];
				}
			}
			else
			{
				if(!tabbed_strings.empty())
				{
					tabbed_strings[tabbed_strings.size()-1].pop_back();

					for(int i = 0; i<tabbed_strings.size(); i++)
					{
						cout <<tabbed_strings[i];
					}
				}
			}
			cout << "}" << endl;
		}
		|
		line program
;



line:
		assignment
		{
			if(expectedTabCounter < tabCounter)
			{
				cout << "tab inconsistency in line "<< linenum << endl;
				exit(0);
			}
			if (!ifVector.empty()){
				if((ifVector.back().type == "if" || ifVector.back().type == "elif" || ifVector.back().type == "else") && !(ifVector.back().tabCount==tabCounter-1) && ifVector.back().closed == false){
					cout << "error in line " << linenum <<": at least one line should be inside if/elif/else block "<< endl;
					exit(0);
				}
			}

			string combined = "";
			if(!ifVector.empty())
			{
				for(int i = ifVector.size()-1; i>=0; i--)
				{
					if(ifVector[i].closed == false && ifVector[i].tabCount>=tabCounter && (ifVector[i].type == "if" || ifVector[i].type == "elif" || ifVector[i].type == "else"))
					{
						for(int j = 0; j < ifVector[i].tabCount; j++ )
						{
							combined += string("\t");
						}
						combined += string("}\n");
						ifVector[i].closed = true;
					}
				}
			}
			combined += string($1) + "\n";			
			ifelifelse currentAssignment;
			currentAssignment.tabCount = tabCounter;
			currentAssignment.type = "assignment";
			currentAssignment.closed = true;
			ifVector.push_back(currentAssignment);

			$$ = strdup(combined.c_str());
			lineStrings.push_back($$);
			tabCounter = 0;
		}
		|
		ifstatement
		{				
			expectedTabCounter = tabCounter + 1;
			tabCounter = 0;		
		}
		|
		NEWLINE
		{
			linenum++;
		}
;
		
ifstatement:
		if
		{
			if (!ifVector.empty()){
				if((ifVector.back().type == "if" || ifVector.back().type == "elif" || ifVector.back().type == "else") && !(ifVector.back().tabCount==tabCounter-1) && ifVector.back().closed == false){
					cout << "error in line " << linenum <<": at least one line should be inside if/elif/else block "<< endl;
					exit(0);
				}
			}

			if (tabCounter > expectedTabCounter ) {
				cout << "there is a tab inconsistency in line "<< linenum << endl;
				exit(0);
			}

			string combined = "";

			if(!ifVector.empty())
			{
				for(int i = ifVector.size()-1; i>=0; i--)
				{
					if(ifVector[i].closed == false && ifVector[i].tabCount>=tabCounter)
					{
						for(int j = ifVector[i].tabCount; j>0; j--)
						{
							combined += string("\t");
						}
						combined += string("}\n");
						ifVector[i].closed = true;
					}
				}
			}

			ifelifelse currentIf;
			currentIf.tabCount = tabCounter;
			currentIf.type = "if";
			currentIf.closed = false;
			ifVector.push_back(currentIf);

			combined = combined + string($1) + "\n";
			$$ = strdup(combined.c_str());
			lineStrings.push_back($$);

		}
		|
		elseif
		{
			if (!ifVector.empty()){
				if((ifVector.back().type == "if" || ifVector.back().type == "elif" || ifVector.back().type == "else") && !(ifVector.back().tabCount==tabCounter-1) && ifVector.back().closed == false){
					cout << "error in line " << linenum <<": at least one line should be inside if/elif/else block "<< endl;
					exit(0);
				}
			}
			string combined = "";
			bool noError = false;

			if(ifVector.empty() == false)
			{
				for(int i = ifVector.size()-1 ; i>=0; i--)
				{
					if( (ifVector[i].tabCount == tabCounter && (ifVector[i].type == "if" || ifVector[i].type == "elif") && ifVector[i].closed == false) )
					{
						noError = true;
					}

					if(ifVector[i].closed == false && ifVector[i].tabCount>=tabCounter)
					{
						for(int j = 0 ; j< ifVector[i].tabCount; j++)
						{
							combined += string("\t");
						}
						combined += string("}\n");
						ifVector[i].closed = true;
					}
				}				
			}
			if(!noError)
			{
				cout << "elif after else in line " << linenum << endl;
				exit(0);
			}
			ifelifelse currentElif;
			currentElif.tabCount = tabCounter;
			currentElif.type = "elif";
			currentElif.closed = false;
			ifVector.push_back(currentElif);

			combined = combined + string($1) + "\n";
			$$ = strdup(combined.c_str());
			lineStrings.push_back($$);

		}
		|
		else
		{
			if (!ifVector.empty()){
				if((ifVector.back().type == "if" || ifVector.back().type == "elif" || ifVector.back().type == "else") && !(ifVector.back().tabCount==tabCounter-1) && ifVector.back().closed == false){
					cout << "error in line " << linenum <<": at least one line should be inside if/elif/else block "<< endl;
					exit(0);
				}
			}
			string combined = "";
			bool noError = false;

			if(ifVector.empty() == false)
			{
				for(int i = ifVector.size()-1 ; i>=0; i--)
				{
					if( (ifVector[i].tabCount == tabCounter && (ifVector[i].type == "if" || ifVector[i].type == "elif") && ifVector[i].closed == false) )
					{
						noError = true;
					}

					if(ifVector[i].closed == false && ifVector[i].tabCount>=tabCounter)
					{
						for(int j = 0 ; j< ifVector[i].tabCount; j++)
						{
							combined += string("\t");
						}
						combined += string("}\n");
						ifVector[i].closed = true;
					}
				}				
			}
			if(!noError)
			{
				cout << "else without if in line " << linenum << endl;
				exit(0);
			}
			ifelifelse currentElse;
			currentElse.tabCount = tabCounter;
			currentElse.type = "else";
			currentElse.closed = false;
			ifVector.push_back(currentElse);

			combined = combined + string($1) + "\n";
			$$ = strdup(combined.c_str());
			lineStrings.push_back($$);

		}
;

assignment:
		IDENTIFIER EQUAL operand
		{

			bool noError = true;
			string expectedType;
			
			if(!typeVec.empty()) 
			{
			  	expectedType = typeVec[0];
			  	for(int i = 1; i < typeVec.size(); i++) 
			  	{
			    	if(typeVec[i] != expectedType) 
			    	{
			      		if((typeVec[i] == "flt" && expectedType == "int") || (typeVec[i] == "int" && expectedType == "flt") ) 
			      		{
			       	 		expectedType = "flt";
			      		}	
			      		else 
			      		{
			        		noError = false;
			      		}
			    	}
			  	}
			}

			if(!noError)
			{
				cout << "type mismatch in line " << linenum << endl;
				exit(0);
			}			

	
							
			Variable temp;
			temp.name = string($1);
			temp.type = expectedType;
			variableVector.insert(variableVector.begin(),temp);

			typeVec.clear();

			string combined = string($1) + "_" + temp.type + " " + string($2) + " " + string($3) + ";";
			$$ = strdup(combined.c_str());
		}
		|
		TAB assignment
		{			
			string combined = string("\t") + string($2);
			$$ = strdup(combined.c_str());
		}
;

operand:
		IDENTIFIER
		{
			string combined = string($1);
			bool flag = false;

			if(!variableVector.empty())
			{				
				for (int i = 0; i < variableVector.size() ; i++)
				{
				    if(variableVector[i].name == $1)
				    {
				    	flag = true;
				        typeVec.push_back(variableVector[i].type);
				        combined += "_" + variableVector[i].type;
				        break;
				    }				    
				}
			}

			if(!flag)
			{
				cout << "Error in line " << linenum <<" :variable not declared."<< endl;
				exit(0);
			}

			$$ = strdup(combined.c_str());
		}
		|
		NUM
		{
			$$ = strdup($1);
			typeVec.push_back("int");
		}
		|
		FLOAT
		{
			$$ = strdup($1);
			typeVec.push_back("flt");	
		}
		|
		STRING
		{			
			$$ = strdup($1);
			typeVec.push_back("str");
		}
		|
		operand OPERATOR operand
		{
			string combined = string($1) +" "+ string($2)+" " + string($3);
			$$ = strdup(combined.c_str());
		}
		|
		OPERATOR operand
		{
			string combined = string($1) + string($2) ;
			$$ = strdup(combined.c_str());
		}		
;


if:
		IF operand COMPARISON operand COLON
		{
			string combined = string($1) + "(" + " " + string($2) + " " + string($3) + " " + string($4) + " " + ")" + "\n";
			for( int i=0; i<tabCounter; i++ )
			{
				combined += "\t";
			}
			combined += "{";

			string currentType = typeVec[0];
			for (int i =1 ; i < typeVec.size(); i++){
				if ( (currentType == "flt" && typeVec[i] == "int") || (currentType == "int" && typeVec[i] == "flt")){
					currentType = "flt";
				}
				else if (typeVec[i] != currentType){
				    cout<<"comparison type mismatch in line "<<linenum<<endl;
			        exit(0);		
				}
			}
			$$ = strdup(combined.c_str());
			typeVec.clear();
		}
		|
		TAB if
		{
			string combined = string("\t") + string($2);
			$$ = strdup(combined.c_str());
		}
;

elseif:
		ELIF operand COMPARISON operand COLON
		{
			string combined = string($1) + "(" + " " + string($2) + " " + string($3) + " " + string($4) + " " + ")" + "\n";
			for( int i=0; i<tabCounter; i++ )
			{
				combined += "\t";
			}
			combined += "{";
			string currentType = typeVec[0];
			for (int i =1 ; i < typeVec.size(); i++){
				if ( (currentType == "flt" && typeVec[i] == "int") || (currentType == "int" && typeVec[i] == "flt")){
					currentType = "flt";
				}
				else if (typeVec[i] != currentType){
				    cout<<"inconsistent type comparison in line "<<linenum<<endl;
			        exit(0);		
				}
			}
			$$ = strdup(combined.c_str());
			typeVec.clear();
		}
		|
		TAB elseif
		{
			string combined = string("\t") + string($2);
			$$ = strdup(combined.c_str());
		}
;

else:
		TAB else
		{
			string combined = string("\t") + string($2);
			$$ = strdup(combined.c_str());
		}
		|
		ELSE COLON
		{
			string combined = string($1) + "\n";
			for( int i=0; i<tabCounter; i++ )
			{
				combined += "\t";
			}
			combined += "{";
			$$ = strdup(combined.c_str());			
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
