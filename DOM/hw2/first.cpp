#include <bits/stdc++.h>
using namespace std;

bool used[26], skip[26];
vector<string> R(26,"");
vector<string> ans(26,"");



void _print(int index, string s){
    sort(s.begin(), s.end());
    s = s+";";
    cout<<(char)(index+'a')<<" ";
    for(int i=s.size()-2; i>-1; i--){
        if(s[i]==s[i+1])continue;
        cout<<s[i];
    }
    if(skip[index])cout<<';';
    cout<<endl;
}

void First(char x){
    used[x-'a'] = false;
    //cout<<x<<"==\n";
    string tmp = R[x-'a'];
    for(int i=0; i<tmp.size(); i++){
        if(tmp[i]=='|'){
            int j=1;
            bool is_skip = false;
            while(tmp[i+j]!='|' && i+j<tmp.size() ){
                if('a'<= tmp[i+j] && tmp[i+j] <= 'z'){
                    if(used[tmp[i+j]-'a']) First(tmp[i+j]);
                    ans[x-'a'] += ans[tmp[i+j]-'a'];
                    if(skip[tmp[i+j]-'a']) {
                       	is_skip = true;
                    }else{
                    	is_skip = false;
                    	break;
					}
                }else if (tmp[i+j]==';'){
                    skip[x-'a']=true;
                    break;
                }else{
                    ans[x-'a'] += tmp[i+j];
                    is_skip = false;
                    break;
                }
                j++;
            }
            if(is_skip) skip[x-'a'] = true;            
        }
    }
}

int main(){
    string non_ter;    
    memset(used,false,sizeof(used));
    memset(skip,false,sizeof(skip));
    while(cin>>non_ter && non_ter!="END_OF_GRAMMAR")   {
        string ruels;
        cin>>ruels;
        R[non_ter[0]-'a'] = "|" + ruels;
        used[non_ter[0]-'a'] = true;
    }
    for(int i=0; i<26; i++){
        if(used[i])  First(i+'a');        
    }
    
    for(int i=25; i>-1; i--){
        if(R[i]!="") _print(i, ans[i]);
    }
    cout<<"END_OF_FIRST\n";
}
