#!/usr/bin/awk -f
# (s)earch for and (u)nblock or (b)lock domains
# (p)rint results, (c)lear search, or (q)uit
# operates on unbound-blocked-hosts.conf (dnsblockbuster output)
# https://codeberg.org/unixsheikh/dnsblockbuster

BEGIN{
  SString=""
  Clear()
  Red="\033[0;31m"
  Green="\033[0;32m"
  None="\033[0m"
}
function Clear(){ split("",Buf) }
function Search(){
  sub(/^s */,"",SString)
  if (length(SString)<=0) return
  Clear()
  cmd=sprintf("grep \"%s\" unbound-blocked-hosts.conf",SString)
  i=1; while (cmd|getline) Buf[i++]=$0; close(cmd)
}
/^s */{ SString=$0; Search() }
/^c/{ Clear() }
/^p/{
  for (i=1;i<=length(Buf);i++){
    Status="[BLOCKED]"; Color=Red
    if (Buf[i]~/^#/) { Status="[UNBLOCKED]"; Color=Green }
    split(Buf[i],Domain,"\"")
    printf("%s%-12s%s %s\n",Color,Status,None,Domain[2])
  }
}
/^u/{
  for (i=1;i<=length(Buf);i++){
    if (Buf[i]~/^#/) continue
    cmd=sprintf("sed -r -i 's/(%s)/#\\1/' unbound-blocked-hosts.conf",Buf[i])
    system(cmd); close(cmd)
  }
  Search()
}
/^b/{
  for (i=1;i<=length(Buf);i++){
    if (Buf[i]!~/^#/) continue
    cmd=sprintf("sed -r -i '/%s/s/^#//' unbound-blocked-hosts.conf",Buf[i])
    system(cmd); close(cmd)
  }
  Search()
}
/^q/{ exit }
