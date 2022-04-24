%{
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
void yyerror(char *message);

%}

%union{
	bool val;
}
%token <val> AND AND_ OR OR_ NOT NOT_ BOOL
%type <val> and or not bool
%%
line		:bool {if($1)printf("true\n"); else printf("false\n");} 
		;
and		:and bool {$$ = $1 & $2; }
		|AND {$$ = $1; }
		;
or		:or bool {$$ = $1 | $2; }
		|OR {$$ = $1; }
		;
not		:not bool {$$ = !$2; }
		|NOT {$$ = $1; }
		;
bool 	:BOOL {$$ = $1; }
		|and AND_ {$$ = $1; }
		|or OR_ {$$ = $1; }
		|not NOT_ {$$ = $1; }
		;

%%
void yyerror(char*message)
{
	fprintf(stderr, "%s\n", message);
}

int main(int argc, char* argv[]){
	yyparse();
	return(0);
}