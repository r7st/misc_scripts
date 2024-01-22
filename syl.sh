#/usr/bin/env bash
# generate fantasy names from english syllables
# prints pronunciation, spelling up for interpretation
# run such as "./syl.sh 10" to generate 10 names

set -e
[[ $1 =~ ^[0-9]+$ ]] || exit 1

OFILE=`mktemp`
curl -s https://web.archive.org/web/20160822211027/http://semarch.linguistics.fas.nyu.edu/barker/Syllables/index.txt | awk '\
BEGIN{ In="false" }
/^=/{ In="true" }
( In=="false" ){ next }
/.*[A-Z]+$/{
  sub(/[A-Z]+.*/,"")
  gsub(/[ \t]*/,"")
  gsub(/[^a-z]/,"")
  print
}' > $OFILE

for i in `seq 1 $1`; do
  for i in `seq 1 $((RANDOM%3+1))`; do
    Si=$(( RANDOM%15708+1 ))
    sed -n ''"${Si}"','"${Si}p"'' $OFILE
  done | tr '\n' '-' | sed 's/-$/\n/'
done | tr '\n' ',' | sed -e 's/,/, /g' -e 's/, $//'; echo
rm $OFILE
