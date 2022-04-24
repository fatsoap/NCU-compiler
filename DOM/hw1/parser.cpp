#include <bits/stdc++.h>
using namespace std;

int point = 0;
vector<string> ans;
string s="";
bool isValid = true;

void program();
void stmts();
void stmt();
void primary();
void primary_tail();


int main()
{
	s="";
	while(getline(cin,s)){
		point = 0;
		program();
	}
	if(isValid){
		for(int i=0; i<ans.size(); i++){
			cout<<ans[i]<<"\n";
		}
	}else{
		cout<<"invalid input\n";
	}
}

void primary_tail(){
	if(point>=s.length()){
		//end
	}else if(s[point]=='.'){
		//DOT
		ans.push_back("DOT .");
		point++;
		if(point>=s.length()){
			isValid = false; //error	
		}else if(s[point]=='"' || ('a'<=s[point] && s[point]<='z') || ('A'<=s[point] && s[point]<='Z') || s[point]=='_' ){
			//ID
			bool pri = true;
			string tmp = "";
			tmp += s[point++];
			for(; point<s.length(); point++){
				if( ('a'<=s[point] && s[point]<='z') || ('A'<=s[point] && s[point]<='Z') || s[point]=='_' || ('0'<=s[point] && s[point]<='9') ){
					tmp += s[point];
				}else{
					pri = false;
					break;
				}
			}
			ans.push_back("ID "+tmp);
			primary_tail();
		}else{
			isValid = false; //error
		}
	}else if(s[point]=='('){
		ans.push_back("LBR (");
		point++;
		if(point>=s.length()){
			isValid = false;
		}else if(s[point]=='"' || ('a'<=s[point] && s[point]<='z') || ('A'<=s[point] && s[point]<='Z') || s[point]=='_' ){
			stmt();
		}
		if(point>=s.length()){
			isValid = false; //error
		}else if(s[point]==')'){
			ans.push_back("RBR )");
			point++;
			primary_tail();
		}else{
			isValid = false; //error	
		}		
	}else{
		isValid = false; //error
	}
}
void primary(){
	//ID();
	bool pri = true;
	string tmp = "";
	tmp += s[point++];
	for(; point<s.length(); point++){
		if( ('a'<=s[point] && s[point]<='z') || ('A'<=s[point] && s[point]<='Z') || s[point]=='_' || ('0'<=s[point] && s[point]<='9') ){
			tmp += s[point];
		}else{
			pri = false;
			break;
		}
	}
	ans.push_back("ID "+tmp);
	
	primary_tail();
}

void stmt(){
	if(s[point]!='"'){
		//primary
		primary();
	}else{
		//STRLIT
		bool STR = true;
		string tmp = "";
		tmp += s[point++];
		for(; point<s.length(); point++){
			tmp += s[point];
			if(s[point]=='"'){
				STR = false;
				point++;
				break;
			}
		}
		if(STR){
			isValid=false; //error
		}else{
			ans.push_back("STRLIT "+tmp);
		}
		
	}	
	//end

}

void stmts(){
	if(point>=s.length()){
		//end;
	}else if(s[point]=='"' || ('a'<=s[point] && s[point]<='z') || ('A'<=s[point] && s[point]<='Z') || s[point]=='_' ){
		stmt();
		stmts();
	}else{
		isValid=false; //error
	}	
}

void program(){
	stmts();
}


