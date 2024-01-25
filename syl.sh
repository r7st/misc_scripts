#!/usr/bin/env bash
# generate fantasy names from english syllables (1 to 3)
# prints pronunciation, spelling up for interpretation
# run such as "./syl.sh -c 10" to generate 10 names
# ./syl.sh -c 1000 -b 50 to generate 1000 names in batches of 50

set -eo pipefail
trap '[ -f $OFILE ] && rm $OFILE; exit' SIGINT SIGTERM
DefaultBatch=20

OFILE=`mktemp`
curl -s https://web.archive.org/web/20160822211027/http://semarch.linguistics.fas.nyu.edu/barker/Syllables/index.txt | awk '\
BEGIN{ In="false" }
/^=/{ In="true" }
(In=="false"){ next }
/.*[A-Z]+$/{
  gsub(/[^a-z]/,"")
  print
}' > $OFILE

CreateName(){
  for i in `seq 1 $((RANDOM%3+1))`; do
    Si=$(( RANDOM%15708+1 ))
    sed -n ''"${Si}"','"${Si}p"'' $OFILE
  done | tr '\n' '-' | sed 's/-$/\n/'
}

Batch(){
  for i in `seq 1 $1`; do
    CreateName &
    Pids[i-1]=$!
  done
  for Pid in "${Pids[*]}"; do
    wait $Pid
  done
}

GenerateNames(){
  [ $Count -le 0 ] && return
  while [ $Count -gt $BatchNum ]; do
    Batch $BatchNum
    ((Count-=BatchNum))
  done
  Batch $Count
}

Usage(){
  echo "Usage: $0 -c <num names> [-b batchsize]" 1>&2
  exit 1
}

while getopts ":c:b:" Op; do
  case "${Op}" in
    c)
      Count="${OPTARG}"
      [[ $Count =~ ^[0-9]+$ ]] || Usage
      [ $Count -ge 0 ] || Usage;;
    b)
      BatchNum="${OPTARG}"
      [[ $BatchNum =~ ^[0-9]+$ ]] || Usage
      [ $BatchNum -gt 0 ] || Usage;;
    *) Usage;;
  esac
done

[ -z $Count ] && Usage
[ -z $BatchNum ] && BatchNum=$DefaultBatch

GenerateNames
