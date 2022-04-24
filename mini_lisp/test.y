%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string>
#include <vector>
#include <map>

using namespace std;
int yylex(void); 
void yyerror(const char *message);

struct Node{
	int type;
	int ival;
	int depth;
	bool bval;
	const char* sval;
	struct Node *lc, *rc;
};

map<string, pair<int,int> > var_table[20];
int table_top = 0;
vector<struct Node*> fun_name_table;

vector<pair<int, int> > params_table;

%}
%union{
int number;
bool boolean;
char c;
const char* word;
struct Node* y_node;
}
%{
struct Node* allocate_Node(int type){
	struct Node* now = (struct Node *)malloc(sizeof(struct Node));
	now->type = type;
	return now;
}
//Str = StrPas(cStr);

pair<int, int> find_table(const char *s){
	string key(s);
	int i=0;
	bool finded = false;
	for(i=table_top; i>-1; i--){
		if(var_table[i].find(key) != var_table[i].end()){ //find
			finded = true;
			return var_table[i][key];
			break;
		}
	}
	return make_pair(0,0);
}

bool push_table(const char *s, int t, int val){
	string key(s);
	int i=0;
	if(var_table[table_top].find(key) == var_table[table_top].end()){ //not find
		var_table[table_top][key] = make_pair(t, val);
		return true;
	}else{
		printf("variable \"%s\" has been define.\n", s);
		return false;
	}
}

bool push_fun(const char*s, struct Node* fun_exp){
	string key(s);
	int i=0;
	if(var_table[table_top].find(key) == var_table[table_top].end()){ //not find
		var_table[table_top][key] = make_pair(4, fun_name_table.size() );
		fun_name_table.push_back(fun_exp);
		return true;
	}else{
		printf("variable \"%s\" has been define.\n", s);
		return false;
	}
}



int dfs(struct Node *now){	 //0: error, 1: int, 2: bool, 3: variable, 4: fun-exp , 5: DC
	//printf("now type is : %d----%d\n", now->type, table_top);
	int lc, rc;
	if(now->type==401){ /* stmt */
		lc = dfs(now->lc);
		if(!lc) return 0;
		return 5;
	}else if(now->type==301){  /* define stmt */
		if(now->rc->type!=-115){
			lc = dfs(now->lc), rc = dfs(now->rc);
			if(!lc || !rc) return 0;
			bool push_ass = false;
			if(rc==1) push_ass = push_table(now->lc->sval, 1, now->rc->ival);
			else if(rc==2)push_ass = push_table(now->lc->sval, 2, now->rc->bval);
			if(!push_ass)return 0;			
			return 5;
		}else{
			lc = dfs(now->lc);
			if(!lc) return 0;
			bool push_ass = push_fun(now->lc->sval, now->rc);
			if(!push_ass) return 0;
			return 5;
		}
		
	}else if(now->type==302){ /* string exp */
		return 3; 
	}else if(now->type==201){ /* print-num */
		lc  = dfs(now->lc);
		if(!lc) return 0;
		if(lc==1) printf("%d\n", now->lc->ival);
		else if(lc==2){
			printf("print-stmt except int , got boolen.\n");
			return 0;
		}
		return 5;
	}else if(now->type==202){   /* print-bool */
		lc = dfs(now->lc);
		if(!lc) return false;
		if(lc==2){
			if(now->lc->bval)printf("#t\n");
			else printf("#f\n");
		}else if(lc==1){
			printf("print-stmt except boolean , got int.\n");
			return 0;
		}
		return 5;
	}else if(now->type==101){   /* number exp */
		return 1;
	}else if(now->type==102){   /* boolean exp */
		return 2;
	}else if(now->type==103){   /* variable exp */
		pair<int,int> tmp = find_table(now->sval);
		if(tmp.first==0){
			printf("variable \"%s\" not defined\n", now->sval);
			return 0;
		}else if(tmp.first==1){
			now->ival = tmp.second;
			return 1;
		}else if(tmp.first==2){
			now->bval = tmp.second;
			return 2;
		}else if(tmp.first==4){
			now->ival = tmp.second;
			return 4;
		}
	}else if(now->type==-104 || now->type==-105 || now->type==-106 || now->type==-112 || now->type==-113 || now->type==-114){  /* gr sm eq and or not -- exp */
		lc = dfs(now->lc); 
		if(!lc) return 0;
		now->bval = now->lc->bval;
		return 2;
	}else if(now->type==-107 || now->type==-108 || now->type==-109 || now->type==-110 || now->type==-111){ /*  plu min mul div mod  -- exp */
		lc = dfs(now->lc); 
		if(!lc) return 0;
		now->ival = now->lc->ival;
		return 1;
	}else if(now->type==-121){  /* if-exp -- exp */
		lc = dfs(now->lc); 
		if(!lc) return 0;
		if(lc==1){
			now->ival = now->lc->ival;
			return 1;
		}else if(lc==2){
			now->bval = now->lc->bval;
			return 2;
		}
	}else if(now->type==104 || now->type==105 || now->type==106 || now->type==108 || now->type==110 || now->type==111){  /* gr sm eq min div mod */
		lc = dfs(now->lc), rc = dfs(now->rc);
		if(!lc || !rc) return 0;
		if(lc==1 && rc==1){
			if(now->type==104)	now->bval = now->lc->ival >  now->rc->ival;
			if(now->type==105)	now->bval = now->lc->ival <  now->rc->ival;
			if(now->type==106)	now->bval = now->lc->ival == now->rc->ival;
			if(now->type==108)	now->ival = now->lc->ival - now->rc->ival;
			if(now->type==110){	
				double a = now->lc->ival, b = now->rc->ival;
				if(a/b >= 0) now->ival = a/b + 0.5;
				else now->ival = a/b - 0.5;	
			}
			if(now->type==111){	
				now->ival = now->lc->ival % now->rc->ival;
			}
			return 1;
		}else if(lc==2 || rc==2){
			printf("params except int , got boolen.\n");
			return 0;
		}
	}else if(now->type==107 || now->type==109){  /* plu mul */
		lc = dfs(now->lc), rc = dfs(now->rc);
		if(!lc || !rc) return 0;
		if(lc==1 && rc==1){
			if(now->type==107)now->ival = now->lc->ival + now->rc->ival;
			else now->ival = now->lc->ival * now->rc->ival;
			return 1;
		}else if(lc==2 || rc==2){
			printf("params except int , got boolen.\n");
			return 0;
		}		
	}else if(now->type==112 || now->type==113){  /* and or */
		lc = dfs(now->lc), rc = dfs(now->rc);
		if(!lc || !rc) return 0;			
		if(lc==2 && rc==2){
			if(now->type==112) now->bval = now->lc->bval & now->rc->bval;
			else now->bval = now->lc->bval | now->rc->bval;
			return 2;
		}else if(lc==1 || rc==1){
			printf("params except boolean , got int.\n");
			return 0;
		}
	}else if(now->type==114){  /* not */
		lc = dfs(now->lc);
		if(!lc) return 0;	
		if(lc==2){
			now->bval = !now->lc->bval;
			return 2;
		}else if(lc==1) {
			printf("params except boolean , got int.\n");
			return 0;
		}
	}else if(now->type==-115){  /* fun-exp --- exp */
		lc = dfs(now->lc);
		if(!lc) return 0;
		if(lc==1){
			now->ival = now->lc->ival;
			return 1;
		}
		if(lc==2){
			now->bval = now->lc->bval;
			return 2;
		}
		if(lc==4){		
			return 4;
		}
	}else if(now->type==115){  /* fun-exp */
		table_top++;
		var_table[table_top].clear();
		if(params_table.size()!=0){
			lc = dfs(now->lc);
			if(!lc){
				table_top--;
				var_table[table_top].clear();
				return 0;
			}
		}		
		rc = dfs(now->rc);
		var_table[table_top].clear();
		table_top--;		
		if(!rc){
			return 0;
		}else if(rc==1){
			now->ival = now->rc->ival;
			return 1;
		}else if(rc==2){
			now->bval = now->rc->bval;
			return 2;
		}
	}else if(now->type==116){  /* fun-ids */		
		if(now->depth==1){
			lc = dfs(now->lc);
			if(!lc) return 0;
			push_table(now->lc->sval, params_table[now->depth-1].first, params_table[now->depth-1].second);
			return 5;
		}else{
			lc = dfs(now->lc), rc = dfs(now->rc);
			if(!lc || !rc) return 0;
			push_table(now->rc->sval, params_table[now->depth-1].first, params_table[now->depth-1].second);
			return 5;			
		}		
	}else if(now->type==117){  /* fun-body */	
		lc = dfs(now->lc);
		if(!lc)return 0;
		if(lc==1){
			now->ival = now->lc->ival;
			return 1;
		} 
		if(lc==2){
			now->bval = now->lc->bval;
			return 2;	
		} 	
	}else if(now->type==-118){  /* fun-call --- exp */
		lc = dfs(now->lc);
		if(!lc){
			return 0;
		}else if(lc==1){
			now->ival = now->lc->ival;
			return 1;
		}else if(lc==2){
			now->bval = now->lc->bval;
			return 2;
		}
	}else if(now->type==118){  /* fun-call */	
		if(now->depth!=0){  //build params table
			params_table.clear();
			rc = dfs(now->rc);
			if(!rc){
				params_table.clear();
				return 0;
			}
		}
		if(now->lc->type==115){
			lc = dfs(now->lc);
			params_table.clear();			
			if(!lc){
				return 0;
			}else if(lc==1){
				now->ival = now->lc->ival;
				return 1;
			}else if(lc==2){
				now->bval = now->lc->bval;
				return 2;
			}
		}else{
			pair<int,int> tmp = find_table(now->lc->sval);
			if(!tmp.first){
				printf("fun name \"%s\" not defined.\n",now->lc->sval);
				return 0;
			} 
			if(tmp.first==4){
				struct Node* fun_ = fun_name_table[tmp.second];
				lc = dfs(fun_);
				params_table.clear();			
				if(!lc){
					return 0;
				}else if(lc==1){
					now->ival = fun_->ival;
					return 1;
				}else if(lc==2){
					now->bval = fun_->bval;
					return 2;
				}					
			}else{
				printf("variable \"%s\" is not a function.\n", now->lc->sval);
				return 0;
			}			
		}
	}else if(now->type==119){  /* param */
		if(now->depth==1){
			lc = dfs(now->lc);
			if(!lc) return 0;
			if(lc==1){
				params_table.push_back(make_pair(1, now->lc->ival) );
				return 5;
			}else if(lc==2){
				params_table.push_back(make_pair(2, now->lc->bval) );
				return 5;
			}			
		}else{
			lc = dfs(now->lc), rc = dfs(now->rc);
			if(!lc || !rc) return 0;
			if(rc==1){
				params_table.push_back(make_pair(1, now->rc->ival) );
				return 5;
			}else if(rc==2){
				params_table.push_back(make_pair(2, now->rc->bval) );
				return 5;
			}				
		}
	}else if(now->type==120){  /* fun-name */
		pair<int,int> tmp = find_table(now->sval);
		if(!tmp.first) return 0;
		
	}else if(now->type==121){  /* if-exp */
		lc = dfs(now->lc);
		if(!lc) return 0;
		if(lc==2){
			rc = dfs(now->rc);
			if(!rc) return 0;
			if(now->lc->bval){
				if(rc/10==1){
					now->ival = now->rc->lc->ival;
					return 1;
				}else if(rc/10==2){
					now->bval = now->rc->lc->bval;
					return 2;
				}
			}else{
				if(rc%10==1){
					now->ival = now->rc->rc->ival;
					return 1;
				}else if(rc%10==2){
					now->bval = now->rc->rc->bval;
					return 2;
				}
			}
		}else if(lc==1){
			printf("if text-exp except boolean , got int.");
			return 0;
		}
	}else if(now->type==122){  /* if-act */
		lc = dfs(now->lc), rc = dfs(now->rc);
		if(!lc || !rc) return 0;
		return lc * 10 + rc;
	}else{
		return 5;
	}
	return 0;
}


%}
%token <number> NUMBER GREATER SMALLER EQUAL PLUS MINUS MULTIPLY DIVIDE MODULUS PRINTNUM
%token <boolean> BOOL AND OR NOT PRINTBOOL DEFINE FUN IF LBRA RBRA
%token <word> ID
%type <y_node> program print-stmt stmt exp greater smaller equal plus minus multiply divide modulus and or not def-stmt variable fun-exp fun-ids fun-body fun-call param fun-name if-check if-act if-exp test-exp then-exp else-exp	
%%
program		:stmt								{$$ = allocate_Node(501); $$->lc = $1; $$->rc = NULL; dfs($1); }
			|program stmt						{$$ = allocate_Node(501); $$->lc = $1; $$->rc = $2; dfs($2); }
			;
stmt 		:exp								{$$ = allocate_Node(401); $$->lc = $1; $$->rc = NULL; }
			|def-stmt							{$$ = allocate_Node(401); $$->lc = $1; $$->rc = NULL; }
			|print-stmt							{$$ = allocate_Node(401); $$->lc = $1; $$->rc = NULL; }
			;
def-stmt	:LBRA DEFINE variable exp RBRA 		{$$ = allocate_Node(301); $$->lc = $3; $$->rc = $4; }
			;
variable	:ID 								{$$ = allocate_Node(302); $$->sval = $1; $$->lc = NULL; $$->rc = NULL; /*throw to table*/}
			;
print-stmt	:LBRA PRINTNUM exp RBRA 			{$$ = allocate_Node(201); $$->lc = $3; }
			|LBRA PRINTBOOL exp RBRA			{$$ = allocate_Node(202); $$->lc = $3; }
			;
exp 		:NUMBER 							{$$ = allocate_Node(101); $$->ival = $1; $$->lc = NULL; $$->rc = NULL; }
			|BOOL								{$$ = allocate_Node(102); $$->bval = $1; $$->lc = NULL; $$->rc = NULL; }
			|variable							{$$ = allocate_Node(103); $$->sval = $1->sval; $$->lc = NULL; $$->rc = NULL; /*check table*/}
			|LBRA greater RBRA 					{$$ = allocate_Node(-104); $$->lc = $2; $$->rc = NULL; }
			|LBRA smaller RBRA 					{$$ = allocate_Node(-105); $$->lc = $2; $$->rc = NULL; }
			|LBRA equal RBRA 					{$$ = allocate_Node(-106); $$->lc = $2; $$->rc = NULL; }
			|LBRA plus RBRA 					{$$ = allocate_Node(-107); $$->lc = $2; $$->rc = NULL; }
			|LBRA minus RBRA 					{$$ = allocate_Node(-108); $$->lc = $2; $$->rc = NULL; }
			|LBRA multiply RBRA 				{$$ = allocate_Node(-109); $$->lc = $2; $$->rc = NULL; }
			|LBRA divide RBRA 					{$$ = allocate_Node(-110); $$->lc = $2; $$->rc = NULL; }
			|LBRA modulus RBRA 					{$$ = allocate_Node(-111); $$->lc = $2; $$->rc = NULL; }
			|LBRA and RBRA 						{$$ = allocate_Node(-112); $$->lc = $2; $$->rc = NULL; }
			|LBRA or RBRA 						{$$ = allocate_Node(-113); $$->lc = $2; $$->rc = NULL; }
			|LBRA not RBRA 						{$$ = allocate_Node(-114); $$->lc = $2; $$->rc = NULL; }
			|fun-exp							{$$ = allocate_Node(-115); $$->lc = $1; $$->rc = NULL; }
			|fun-call							{$$ = allocate_Node(-118); $$->lc = $1; $$->rc = NULL; }
			|if-exp  							{$$ = allocate_Node(-121); $$->lc = $1; $$->rc = NULL; }
			;
greater		:GREATER exp exp					{$$ = allocate_Node(104); $$->lc = $2; $$->rc = $3;}
			;
smaller		:SMALLER exp exp				    {$$ = allocate_Node(105); $$->lc = $2; $$->rc = $3;}
			;
equal		:EQUAL exp exp						{$$ = allocate_Node(106); $$->lc = $2; $$->rc = $3;}
			;
plus		:PLUS exp exp						{$$ = allocate_Node(107); $$->depth = 2; $$->lc = $2; $$->rc = $3;}
			|plus exp 							{$$ = allocate_Node(107); $$->depth = $1->depth+1; $$->lc = $1; $$->rc = $2; }
			;
minus 		:MINUS exp exp				 		{$$ = allocate_Node(108); $$->lc = $2; $$->rc = $3;}
			;
multiply	:MULTIPLY exp exp					{$$ = allocate_Node(109); $$->depth = 2; $$->lc = $2; $$->rc = $3;}
			|multiply exp 						{$$ = allocate_Node(109); $$->depth = $1->depth+1; $$->lc = $1; $$->rc = $2; }
			;
divide		:DIVIDE	exp exp				  		{$$ = allocate_Node(110); $$->lc = $2; $$->rc = $3;}
			;		
modulus		:MODULUS exp exp 					{$$ = allocate_Node(111); $$->lc = $2; $$->rc = $3;}
			;
and			:AND exp exp						{$$ = allocate_Node(112); $$->depth = 2; $$->lc = $2; $$->rc = $3;}
			|and exp 							{$$ = allocate_Node(112); $$->depth = $1->depth+1; $$->lc = $1; $$->rc = $2; }
			;
or			:OR exp exp							{$$ = allocate_Node(113); $$->depth = 2; $$->lc = $2; $$->rc = $3;}
			|or exp 							{$$ = allocate_Node(113); $$->depth = $1->depth+1; $$->lc = $1; $$->rc = $2; }
			;	
not			:NOT  exp							{$$ = allocate_Node(114); $$->lc = $2;}
			;
fun-exp		:LBRA FUN fun-ids fun-body RBRA 	{$$ = allocate_Node(115); $$->lc = $3; $$->rc = $4;}
			;
fun-ids		:LBRA RBRA							{$$ = allocate_Node(116); $$->depth = 0; $$->lc = NULL; $$->rc = NULL;}
			|variable							{$$ = allocate_Node(116); $$->depth = 1; $$->lc = $1; $$->rc = NULL;}
			|LBRA fun-ids RBRA					{$$ = $2;}
			|fun-ids variable					{$$ = allocate_Node(116); $$->depth = $1->depth+1; $$->lc = $1; $$->rc = $2;}
			;
fun-body	:exp								{$$ = allocate_Node(117); $$->lc = $1; $$->rc = NULL;}
			;
fun-call	:LBRA fun-exp param RBRA			{$$ = allocate_Node(118); $$->depth = 1; $$->lc = $2; $$->rc = $3; }
			|LBRA fun-name param RBRA			{$$ = allocate_Node(118); $$->depth = 1; $$->lc = $2; $$->rc = $3; }
			|LBRA fun-exp RBRA					{$$ = allocate_Node(118); $$->depth = 0; $$->lc = $2; $$->rc = NULL;}
			|LBRA fun-name RBRA					{$$ = allocate_Node(118); $$->depth = 0; $$->lc = $2; $$->rc = NULL;}
			;
param		:exp								{$$ = allocate_Node(119); $$->depth = 1; $$->lc = $1; $$->rc = NULL; }
			|param exp 							{$$ = allocate_Node(119); $$->depth = $1->depth+1; $$->lc = $1; $$->rc = $2; }
			;
fun-name	:ID									{$$ = allocate_Node(120); $$->sval = $1; $$->lc = NULL; $$->rc = NULL; }
			;
if-exp		:LBRA if-check if-act RBRA			{$$ = allocate_Node(121); $$->lc = $2; $$->rc = $3; }
			;			
if-check	:IF test-exp 						{$$ = $2;}
			;
test-exp	:exp								{$$ = $1;}
			;			
if-act		:then-exp else-exp					{$$ = allocate_Node(122); $$->lc = $1; $$->rc = $2; }
			;
then-exp	:exp								{$$ = $1;}
			;
else-exp	:exp								{$$ = $1;}
			;

%%
void yyerror(const char *message) {
    fprintf (stderr, "%s\n",message);
}

int main(int argc, char *argv[]) {
    yyparse();  
    return(0);
}
