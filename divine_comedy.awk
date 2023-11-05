# Dante Alighieri's Divine Comedy (Project Gutenberg)
# https://www.gutenberg.org/files/8800/8800-h/8800-h.htm
# script to parse the html to sectioned/numbered plaintext
# wget and run dos2unix first

BEGIN{ 
  print "Dante Alighieri's Divine Comedy" 
  print "Translated: Rev. H. F. Cary"
  print "Illustrated: Gustave Doré (not shown)"
  print "Produced: David Widger"
  print "Hosted: Project Gutenberg"
  print "Link: https://www.gutenberg.org/files/8800/8800-h/8800-h.htm"
  InCanto="false"; LN=1; printf("\n")
}
/name=\"canto.*((HELL)|(PURGATORY)|(PARADISE))/{ 
  gsub(/<[^>]*>/,"",$0); Line="[Cantica "$0"]"
  printf("\n\n\n%25s\n\n",Line)
}
/CANTO [IVXLCDM]*/{ 
  gsub(/<[^>]*>/,"",$0); sub(/CANTO /,"",$0); LN=1
  Line="[Canto "$0"]"; printf("\n\n%25s\n\n",Line)
}
/<\/p>/{ InCanto="false" }
(InCanto=="true"){
  gsub(/<br\/?>/,"",$0)
  if ($0 !~ /^$/) { printf("%3d| ",LN++) }
  print
}
/<p>/{ InCanto="true"; printf("\n") }
