%{
#include <stdbool.h>
#include "y.tab.h"
#include<stdlib.h>

%}

%%
[<]and[>] 	{yylval.val = true; return AND; /* return and */}
[<][/]and[>] 	{yylval.val = true; return AND_; /* return /and */}
[<]or[>] 		{yylval.val = false; return OR; /* return or */}
[<][/]or[>] 	{yylval.val = true; return OR_; /* return /or */}
[<]not[>] 	{yylval.val = true; return NOT; /* return not */}
[<][/]not[>] 	{yylval.val = true; return NOT_; /* return /not */}
[<]true[/][>] 	{yylval.val = true; return BOOL; /* return true */}
[<]false[/][>]	{yylval.val = false; return BOOL; /* return false */}
[ \t\n]+	;
. 		{ return(yytext[0]); }
%%
