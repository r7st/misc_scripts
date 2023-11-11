#!/usr/bin/env awk -f
# adds randomized hashtags to input based on word length
BEGIN{ srand() }
{
  gsub(/ +/," "); gsub(/((^ +)|( +$))/,"")
  N=split($0,Words," "); if (N<=0) next
  NumTags=int((rand()*100%N+1)/2)
  if (NumTags<=0) NumTags++
  PrWords=""; for (i=1;i<=length(Words);i++)
    PrWords=sprintf("%s %d,%s",PrWords,length(Words[i]),Words[i])
  sub(/^ /,"",PrWords)
  cmd=sprintf("echo \"%s\" | tr ' ' '\n' | sort -rn",PrWords)
  i=1; while (cmd|getline){
    sub(/^[0-9]+,/,""); SoWords[i++]=$0
  } close(cmd)
  for (i=1;i<=length(SoWords);i++){
    if (i>NumTags) SoWords[i]=""
  } TagSentence="";
  for (i=1;i<=length(Words);i++){
    Word=Words[i]; 
    for (j=1;j<=length(SoWords);j++){
      if (Word==SoWords[j]){
        Word="#"SoWords[j]
        SoWords[j]=""
      }
    }
    TagSentence=sprintf("%s %s",TagSentence,Word)
  }
  gsub(/((^ +)|( +$))/,"",TagSentence)
  printf("[Hashtagified]: %s\n",TagSentence)
}
