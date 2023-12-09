# parse joe conf options
BEGIN{ Es=1; Ds=1; Os=1 }
/^ *Status line definition/{ exit }
/ ?--?option.*/{ next }
(match($0,/^ ?--?[^ \t]+ ?((n+)|([0-9]+))?/)>0){
  Op=substr($0,RSTART,RLENGTH)
  sub(/[ \t]$/,"",Op)
  if (sub(/^--/,"",Op)>0) DISABLED[Ds++]=Op
  else if (sub(/^-/,"",Op)>0) ENABLED[Es++]=Op
  else if (sub(/^ -/,"",Op)>0) OPTIONS[Os++]=Op
}
END{
  print "=== ENABLED ==="
  for(i=1;i<=Es;i++) print ENABLED[i]
  print "=== DISABLED ==="
  for(i=1;i<=Ds;i++) print DISABLED[i]
  print "=== OPTIONS ==="
  for(i=1;i<=Os;i++) print OPTIONS[i]
}
