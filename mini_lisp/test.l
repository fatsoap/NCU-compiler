%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include "y.tab.h"
/* yylval type
string {
	yylval.word = strdup(yytext);
}
double{
	char* eptr;
	yylval.num = strtod(yytext, &eptr);
}
int {
	yylval.num = atoi(yytext);
}
bool{
	yylval.boolean = true/false;
}
*/
bool check(char* s){
    long long int tmp;
    sscanf(s,"%lld",&tmp); 
    if(-2147483648 <= tmp && tmp <= 2147483647) return true;
    printf("number out of range.\n");
    return false;
}
%}
separator [\t]|[\n]|[\r]|[ ]
char [a-z]
digit [0-9]
id {char}({char}|{digit}|[-])*
num 0|[1-9]{digit}*|[-][1-9]{digit}*

%%
{separator}	;
{num} 		{ if(!check(yytext)) return 0; yylval.number = atoi(yytext); return NUMBER; }
[#]t			{yylval.boolean = true; 		return BOOL; }
[#]f			{yylval.boolean = false; 		return BOOL; }
[>]  			{yylval.number  = 1; 			return GREATER; }
[<]  			{yylval.number  = 1; 			return SMALLER; }
[=]	  		{yylval.number  = 1; 			return EQUAL; }
[+]			{yylval.number  = 1; 			return PLUS; }
[-]			{yylval.number  = 1; 			return MINUS; }
[*]			{yylval.number  = 1; 			return MULTIPLY; }
[/]			{yylval.number  = 1; 			return DIVIDE; }
[(]			{yylval.boolean  = true; 		return LBRA; }
[)]			{yylval.boolean  = true; 		return RBRA; }
mod		{yylval.number  = 1; 	        	return MODULUS; }
and			{yylval.boolean = true; 	     	return AND; }
or			{yylval.boolean = true;            	return OR; }
not			{yylval.boolean = true; 	      	return NOT; }
print[-]num	{yylval.number  = 1; 			return PRINTNUM; }
print[-]bool	{yylval.boolean = true;			return PRINTBOOL; }
define 		{yylval.boolean = true;			return DEFINE; }
fun 			{yylval.boolean = true;			return FUN; }
if			{yylval.boolean = true;			return IF; }
{id}			{yylval.word = strdup(yytext);	return ID; }
. 			{							return(yytext[0]); }
%%
