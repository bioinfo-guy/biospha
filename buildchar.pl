#!/usr/bin/perl -w
    use DBI;
    use Bio::SeqIO;
    use Data::Dumper;
    use Bio::DB::Taxonomy;
    my $usage = "rebuildfasta.pl infile Cod> outfile \n";
    my $infile = shift or die $usage;
    my $Cod = shift or die $usage;
    #my $outfile = shift or die $usage;
    my $inseq = Bio::SeqIO->new(-file   => "<$infile",
                                                   -format => "fasta" );

#Conecta ao baco de taxonomia
my $idx_dir = '/home/user/taxonomy/idx';
my $db = new Bio::DB::Taxonomy(-source    => 'flatfile',
			       -nodesfile => '/home/user/taxonomy/nodes.dmp',
			       -namesfile => '/home/user/taxonomy/names.dmp',
			       -directory => $idx_dir);

#Conecta ao banco de dados SQLite
$dbh = DBI->connect("dbi:SQLite:dbname=/home/user/taxonomy/taxonomy.db", "", "
",
                    { RaiseError => 1, AutoCommit => 0 });

#checa se há os arquivos temporários
$file = "Nomes_$Cod.txt"; #nome das sequencias e filos
$file2 = "Filos_$Cod.txt"; #filos únicos
#grava 

open (MYFILE, ">>$file2");	  
#gravando no arquivo

print MYFILE "Streptophyta\n";
close (MYFILE);

#apgar file
#if (unlink($file) == 0) {
    #print "File deleted successfully.";
#} else {
    #print "File was not deleted.";
#}


#Rotina de busca dentro da lista ge taxid
sub classifica
{
my ($a) = @_;
my $node = $db->get_Taxonomy_Node(-taxonid => $a);
#Marca o primeiro parent_id
$parent = $node->parent_id;
#faz looping até final da classificação
while( (defined $parent))  {
my $node = $db->get_Taxonomy_Node(-taxonid => $parent);
#pega o genero da espécie
if ($node->rank eq "genus") {
$especie = $node->scientific_name;
}
#pega o filo
if ($node->rank eq "phylum") {
#print $node->rank,"\t", $node->scientific_name, "\n";
$filo = $node->scientific_name;
}
if ($node->rank eq "phylum") {
$phylum = $node->scientific_name;
}
if ($node->rank eq "class") {
$class = $node->scientific_name;
}
$parent = $node->parent_id;
} 
}


    while (my $seq = $inseq->next_seq) { #abre loop dentro do arquivo fasta
#separa nome da espécie
$teste = $seq->desc;
$teste =~ s/^(.*)\[(.*)\]/\2/;
#pega somente o primeiro nome da sp
$teste =~ s/(\w+)(.*)/\1/;
#Separa id
@separa = split(/\|/, $seq->id);

#Busca o GI no banco de dados
my $all = $dbh->selectall_arrayref("SELECT * FROM gi2tax WHERE gi = $separa[1]");
  foreach my $row (@$all) {
    my ($gi, $taxid) = @$row;
&classifica($taxid);
}
	  
#Coloca cada filo em um array
push(@in, $filo);
#abre arquivo temporário
open (MYFILE, ">>$file");	  
#gravando no arquivo
$filo =~ s/\-/\_/g;
print MYFILE $especie,"_",$class,"_",$phylum,"_",$separa[1],"\t",$filo,"\n";
close (MYFILE);
    } #Fecha loop dentro do arquivo

#Monta somente não duplicados no array de filos
undef %saw;
    @out = grep(!$saw{$_}++, @in);
print "Array original: ",scalar(@in),"\n";
print "Array filtrado: ",scalar(@out),"\n";


#monta o bloco de comandos
###################################################################
#               Início do cabeçalho
###################################################################

print ">>>>>>>>>>>>>>>>>>>>COPY FROM HERE<<<<<<<<<<<<<<<<<<<<\n\n";
print "BEGIN CHARACTERS;\n";
print "	\tTITLE  Matrix_1;\n";
print "	\tDIMENSIONS  NCHAR=1;\n";
print "	\tFORMAT DATATYPE = STANDARD GAP = - MISSING = ? SYMBOLS = \"A";
#monta o número de caracteres sendo que "0" já está definido como Streptophyta
$conta = B;
foreach $i (@out) {
    print " $conta";
###################################################################
#               Grava os filos dentro de um arquivo
###################################################################

open (MYFILE, ">>$file2");	  
#gravando no arquivo
$i =~ s/\-/\_/g;
print MYFILE $i,"\n";
close (MYFILE);
###################################################################
#               Fim Grava os filos dentro de um arquivo
###################################################################
$conta ++,
}
print "\"\;	CHARSTATELABELS\n";
print "\t\t 1 Bact \/ Streptophyta ";
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
$conta = B;
foreach $i (@out) {
$i =~ s/\-/\_/g;
$_ =~ s/\t$i/\t$conta/g;
$conta ++;
}
print "$_\n";
}
close (MYFILE);
print "\;\n";
print "\tEND\;\n";

print "\n\n>>>>>>>>>>>>>>>>>>>>COPY UNTIL HERE<<<<<<<<<<<<<<<<<<<<\n\n";
#apaga arquivo temporário
#unlink($file);
exit;
