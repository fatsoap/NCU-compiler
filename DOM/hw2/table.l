%{
#include <stdio.h>
int i=0;
%}
IP_d (([0-9])|([1-9][0-9])|(1[0-9][0-9])|(2[0-4][0-9])|(25[0-5]))
%%
^[a-zA-Z0-9]+[@][a-zA-Z0-9]+([.][a-zA-Z0-9]+)+$  {printf("%s is an email address\n", yytext);}
^[A-Z][A-Za-z]*$  {printf("%s is a word\n", yytext);}
^{IP_d}[.]{IP_d}[.]{IP_d}[.]{IP_d}$		{printf("%s is an IP address\n",yytext);}
[ \t\n] ; 
.       ;
%%
int main(int argc, char *argv[]){
	yylex();
	return(0);
}
