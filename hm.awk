function Show(Arg){
  if (Arg=="ssh"){
    Conf=ENV["HOME"]"/.ssh/config"
    while ((getline<Conf)>0){
      if (sub(/^[Hh]ost +/,"")==1) print
    } close(Conf); exit
  } else if (Arg=="rc"){
    cmd=sprintf("find %s -maxdepth 1 -type f -regex \".*\..*rc\" \
      -exec basename {} \\; | sort", ENV["HOME"])
    i=0; while (cmd|getline) Files[i++]=$0; close(cmd)
    for (i in Files){ j=0; print "\nContents of: "Files[i]
      while((getline<(ENV["HOME"]"/"Files[i]))>0) 
        printf("%3d: %s\n",j++,$0); close(Files[i])
    }
  } else { return }; exit
}
function Define(Arg){
  cmd="curl -s dict://dict.org/d:"Arg
  while (cmd|getline) { if ($0!~/^[0-9.]/) print }
  close(cmd); exit
}
function Where(){
  cmd="curl -s ipinfo.io"
  while(cmd|getline){
    gsub(/ *\":?,?/,"")
    if (sub(/^city/,"")==1) City=$0
    else if (sub(/^region/,"")==1) Region=$0
    else if (sub(/^country/,"")==1) Country=$0
  } close(cmd); printf("%s, %s - %s\n", City, Region, Country); exit
}
BEGIN{ 
  FS="="; cmd="env";
  while(cmd|getline) ENV[$1]=$2
  close(cmd); FS=" "
  $0=tolower($0)
  gsub(/[^[a-zA-Z0-9-_ ]/,"")
  gsub(/((^ *)|( *$))/,"")
}
/^show *[^ ]+/{ Show($2) }
/^define *[^ ]/{ Define($2) }
/^where( *am *i\??)? *$/{ Where() }
{ print "what?" }
