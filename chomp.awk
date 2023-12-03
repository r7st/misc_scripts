#!/usr/bin/awk -f
# safely remove empty lines and comments from
# configuration files. CM is Comment Marker

BEGIN{ if (length(CM)<=0) CM="#" }
/^[ \t]*$/{ next }
function TestLength(TString){
  gsub(/[ \t]*/,"",TString)
  return length(TString)>0
}
{
  split($0,Buf,"")
  InCom="false"; Line=""
  for (i=1;i<=length(Buf);i++){
    C=Buf[i]
    if (C~/"|'/){
      if (InCom=="false") InCom="true"
      else InCom="false"
    }
    if (C==CM && InCom=="false"){
      if (TestLength(Line)){
        sub(/[ \t]*$/,"",Line)
        print Line
      }
      next
    }
    Line=sprintf("%s%s",Line,C)
  }
  if (TestLength(Line)) print Line
}
