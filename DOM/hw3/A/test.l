%{
#include "y.tab.h"
#include<stdlib.h>

%}
digit [0-9]
num {digit}+
%%
\n		{return(0); /* EOF */ }
{num} 	{yylval.leaf = strdup(yytext); return LEAF; /* return str */}
[ \t]+	;
. 		{ return(yytext[0]); }
%%
