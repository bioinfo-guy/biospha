#!/usr/bin/perl
    my $usage = "First run buildchar.pl then buildptp.pl infile Cod > outfile \n";
    my $Cod = shift or die $usage;

# @out = array com os nomes dos filos

#checa se há os arquivos temporários
$file = "Nomes_$Cod.txt"; #nome das sequencias e filos
$file2 = "Filos_$Cod.txt"; #filos únicos

###################################################################
#               coloca os filos em array
###################################################################

open (MYFILE, "$file2");
while (<MYFILE>) {
chomp;
push(@out, $_);
}
close (MYFILE);

#monta o bloco de comandos
$matrix = 0;
print ">>>>>>>>>>>>>>>>>>>>COPY FROM HERE<<<<<<<<<<<<<<<<<<<<\n\n";
while ($matrix < 300) {
###################################################################
#               Início do cabeçalho
###################################################################

print "BEGIN CHARACTERS;\n";
print "	\tTITLE ", $matrix,";\n";
print "	\tDIMENSIONS  NCHAR=1;\n";
print "	\tFORMAT DATATYPE = STANDARD GAP = - MISSING = ? SYMBOLS = \"";
#monta o número de caracteres sendo que "0" já está definido como Streptophyta
$conta = A;
foreach $i (@out) {
    print " $conta";
push(@filo, $conta);#coloca as letras dos filos no array
$conta ++,
}
print "\"\;	CHARSTATELABELS\n";
print "\t\t 1 Bact \/ ";
#monta os nomes dos caracteres
foreach $i (@out) {
    print "\U$i\E ";
}
print "\;\n\tMATRIX\n";
###################################################################
#               Fim do cabeçalho
################################################################### 

###################################################################
#               Inicio da matrix de dados
################################################################### 
open (MYFILE, "$file");
while (<MYFILE>) {
chomp;
#troca os nomes dos caracteres pelos números
#$conta = A;
#$Quantos = scalar(@out); #conta quantos filos tem no arquivo
foreach $i (@out) {
#@abc = (A .. Z)[0..$quantos];#gera array com $quantos letras 
$draw = @filo[rand @filo]; #pega uma letra aleatória no @abc 
$_ =~ s/$i/$draw/g;
#$conta ++;
}
print "$_\n";
}
close (MYFILE);
print "\;\n";
print "\tEND\;\n";
$matrix ++;
}; # fecha loop para montagem da matriz
print "\n\n>>>>>>>>>>>>>>>>>>>>COPY UNTIL HERE<<<<<<<<<<<<<<<<<<<<\n\n";
#apaga arquivo temporário
#unlink($file);
exit;
