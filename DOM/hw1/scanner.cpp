#include <bits/stdc++.h>
using namespace std;

int main()
{
	char c;
	bool isNum = false;
	string num = "";
	vector<string> v;
	while(cin>>c){
		if(isNum){
			if('0'<=c && c<='9'){
				num += c;
			}else{
				isNum = false;
				v.push_back("NUM "+num);
				if(c=='('){
					v.push_back("LPR");
				}else if(c==')'){
					v.push_back("RPR");
				}else if(c=='+'){
					v.push_back("PLUS");
				}else if(c=='-'){
					v.push_back("MINUS");
				}else if(c=='*'){
					v.push_back("MUL");
				}else if(c=='/'){
					v.push_back("DIV");	
				}
			}
		}else{
			if(c=='('){
				v.push_back("LPR");
			}else if(c==')'){
				v.push_back("RPR");
			}else if(c=='+'){
				v.push_back("PLUS");
			}else if(c=='-'){
				v.push_back("MINUS");
			}else if(c=='*'){
				v.push_back("MUL");
			}else if(c=='/'){
			v.push_back("DIV");	
			}
			if('0'<=c && c<='9'){
				num = c;
				isNum = true;
			}
		}
	}
	if(isNum){
		isNum = false;
		v.push_back("NUM "+num);
	}
	for(int i=0; i<v.size(); i++){
		cout<<v[i]<<"\n";
	}
}

