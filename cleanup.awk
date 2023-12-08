#!/usr/bin/awk -f

BEGIN{
  SAFE=1
  CONF="./cleanup.conf"
  ReadConf()
  GetMove()
  Execute()
}

function ReadConf(){
  Path="."; i=1; j=1
  while ((getline<CONF)>0){
    if (match($0,/^[ \t]*#/)>0) continue
    else if (sub(/^\=/,"")) Dest=$0
    else if (sub(/^\+/,"")){ 
      Path=$0
      Paths[j,1]=Path
      Paths[j,2]=Dest
      Paths["size"]=j++
    }
    else{
      Keep[i,1]=Path"/"$0
      Keep[i,2]=Dest
      Keep["size"]=i++
    }
  }
}

function GetMove(){
  j=1
  for (i=1;i<=Paths["size"];i++){
    cmd=sprintf("find %s/* -maxdepth 0 2>/dev/null",Paths[i,1])
    while (cmd|getline){
      Files[j,1]=$0;
      Files[j,2]=Paths[i,2]
      Files["size"]=j++
    }
    close(cmd)
  }
  k=1;
  for (i=1;i<=Files["size"];i++){
    Drop="false"
    for(j=1;j<=Keep["size"];j++){
      if (Files[i,1] == Keep[j,1]) Drop="true" 
    }
    if (Drop!="false") continue
    Move[k,1]=Files[i,1]
    Move[k,2]=Files[i,2]
    Move["size"]=k++
  }
}

function Execute(){
  for (i=1;i<=Move["size"];i++){
    cmd=sprintf("mv -nv %s %s",Move[i,1],Move[i,2])
    if (SAFE) print cmd
    else while (cmd|getline) print; close(cmd)
  }
}
