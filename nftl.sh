#!/usr/bin/env bash
# print sorted nftables rules
# depends on matching comments

nft list ruleset | awk '
function GComm(Line){
  if (match(Line,/comment "[^"]+"$/)<=0) return
  C=substr(Line,RSTART,RLENGTH-1)
  sub(/^.*"/,"",C); return "# "C
}
function RSplit(Line){
  split(Line,R,":")
  if (length(G=GComm(R[2]))>0) print G
  for (i=2;i<=length(R);i++){
    sub(/comment .*$/,"",R[i])
    sub(/ counter.*bytes [0-9]+/,"",R[i])
    print R[i]
  } print ""
}
(match($0,/comment "[^"]+"$/)>0){
  sub(/^[ \t]*/,"")
  I=substr($0,RSTART,RLENGTH-1)
  sub(/comm.*"/,"",I)
  Rules[I]=Rules[I]":"$0
}
END{ for (i in Rules){ RSplit(Rules[i]) } }
'
