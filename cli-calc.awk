# rlwrap awk -f cli-calc.awk
BEGIN{ printf "Starting cli-calc...\n> " }
/^q$/{ print "Exiting cli-calc..."; exit }
{
  cmd="echo \""$0"\" | bc -l"
  while (cmd | getline){ print }
  printf("> ")
  next
}
{ printf("> ") }
