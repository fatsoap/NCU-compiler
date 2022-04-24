%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

struct node{
	int lc, rc;
	double val;
	char s[10];
};

void yyerror(char *message);

struct node st[100];
int top = 0;

void dfs(int now){
	if(now==-1)return;
	printf(" ");
	printf("%s",st[now].s);
	dfs(st[now].lc);
	dfs(st[now].rc);
}

/* LEAF to VERTIC
int i=0;
for(i=0; $1[i]!='\0'; i++){
	st[top].s[i] = $1[i];
}
st[top].s[i] = '\0';
st[top].val = atoi($1);
st[top].lc = -1;
st[top].rc = -1;
$$ = top;
top++;

*/
/* VERTIC calculate
st[top].lc = $1;
st[top].rc = $3;
st[top].val = st[$1].val __ st[$3].val;
st[top].s[0] = __;
$$ = top;
top++;
*/

%}

%union{
	char* leaf;
	int index;
}
%token <leaf> LEAF
%type <index> VERTIC
%left '+' '-'
%left '*' '/'
%%
line 		:VERTIC { 
			printf("the preorder expression is :");
			dfs($1);
			if(st[$1].val>=0)printf("\nthe result is : %d\n", (int)(st[$1].val+0.5));
			else printf("\nthe result is : %d\n", (int)(st[$1].val-0.5));
		}
		;
VERTIC	:VERTIC '+' VERTIC {
			st[top].lc = $1;
			st[top].rc = $3;
			st[top].val = st[$1].val + st[$3].val;
			st[top].s[0] = '+';
			$$ = top;
			top++;
		} 
		|VERTIC '-' VERTIC {
			st[top].lc = $1;
			st[top].rc = $3;
			st[top].val = st[$1].val - st[$3].val;
			st[top].s[0] = '-';
			$$ = top;
			top++;
		} 
		|VERTIC '*' VERTIC {
			st[top].lc = $1;
			st[top].rc = $3;
			st[top].val = st[$1].val * st[$3].val;
			st[top].s[0] = '*';
			$$ = top;
			top++;
		} 
		|VERTIC '/' VERTIC {
			st[top].lc = $1;
			st[top].rc = $3;
			st[top].val = st[$1].val / st[$3].val;
			st[top].s[0] = '/';
			$$ = top;
			top++;
		} 
		|'(' VERTIC ')' {$$ = $2;}
		|LEAF {
			int i=0;
			for(i=0; $1[i]!='\0'; i++){
				st[top].s[i] = $1[i];
			}
			st[top].s[i] = '\0';
			st[top].val = atoi($1);
			st[top].lc = -1;
			st[top].rc = -1;
			$$ = top;
			top++;
		}
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