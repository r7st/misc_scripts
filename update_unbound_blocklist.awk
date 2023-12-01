#!/usr/bin/awk -f
# (s)earch for and (u)nblock or (b)lock domains
# (p)rint results, (c)lear search, or (q)uit
# operates on unbound-blocked-hosts.conf (dnsblockbuster output)
# https://codeberg.org/unixsheikh/dnsblockbuster

BEGIN{ SString=""; Clear() }
function Clear(){ split("",Buf) }
function Search(){
  sub(/^s */,"",SString)
  if (length(SString)<=0) return
  Clear()
  cmd=sprintf("grep \"%s\" unbound-blocked-hosts.conf",SString)
  i=1; while (cmd|getline) Buf[i++]=$0; close(cmd)
}
/^s */{ SString=$0; Search() }
/^c/{ split("",Buf) }
/^p/{ for (i=1;i<=length(Buf);i++) { print Buf[i]} }
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
    cmd=sprintf("sed -r -i 's/^#//' unbound-blocked-hosts.conf",Buf[i])
    system(cmd); close(cmd)
  }
  Search()
}
/^q/{ exit }
