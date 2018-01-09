clear
#gera diretório temporário
mkdir temp
for filename in $1
do
echo "$filename..."

echo "Checking file $filename...\n"

echo "Converting from fasta to tab"
perl -e '$count=0; $len=0; while(<>) {s/\r?\n//; s/\t/ /g; if (s/^>//) { if ($. != 1) {print "\n"} s/ |$/\t/; $count++; $_ .= "\t";} else {s/ //g; $len += length($_)} print $_;} print "\n"; warn "\nConverted $count FASTA records in $. lines to tabular format\nTotal sequence length: $len\n\n";' $filename > temp/dup.tab

echo "Searching for duplicates"

perl -e '$column = 2; $unique=0; while(<>) {s/\r?\n//; @F=split /\t/, $_; if (! ($save{$F[$column]}++)) {print "$_\n"; $unique++}} warn "\nChose $unique unique lines out of $. total lines.\nRemoved duplicates in column $column.\n\n"' temp/dup.tab > temp/unique.tab

echo "Generating uniques"


FN=`echo $filename | awk 'BEGIN { FS="."}{print $1}'` 
diff -u -i -b -a temp/unique.tab temp/dup.tab > $FN.diff

perl -e '$len=0; while(<>) {s/\r?\n//; @F=split /\t/, $_; print ">$F[0]"; if (length($F[1])) {print " $F[1]"} print "\n"; $s=$F[2]; $len+= length($s); $s=~s/.{60}(?=.)/$&\n/g; print "$s\n";} warn "\nConverted $. tab-delimited lines to FASTA format\nTotal sequence length: $len\n\n";' temp/unique.tab > $FN.uni

echo "Deleting temp files".

rm temp/*.*

done

rm -r temp/
