BEGIN{ printf "Starting reg-check...\n> "; INP="" }
/^q$/{ exit }
/^inp/{
  sub("^inp[ \t]*","")
  INP=$0
  printf("> "); next
}
/^try +\/[^\/]+\// && (INP!=""){
  sub("^try[ \t]*","")
  cmd="sed -rn \'"$0"p\' <<< "INP
  while (cmd | getline){ print }
  printf("> "); next
}
{ printf("> ") }
END{ print "Exiting..." }
