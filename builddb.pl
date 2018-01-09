#!/usr/bin/perl -w
use DBI;
use Bio::DB::Taxonomy;
use Data::Dumper;

#abre arquivos de taxonomia

my $idx_dir = '/home/user/taxonomy/idx';
my $db = new Bio::DB::Taxonomy(-source    => 'flatfile',
			       -nodesfile => '/home/user/taxonomy/nodes.dmp',
			       -namesfile => '/home/user/taxonomy/names.dmp',
			       -directory => $idx_dir);

#Abre o arquivo fasta para consulta    

    use Bio::SeqIO;
    my $usage = "builddb.pl file format\n";
    my $file = shift or die $usage;
    my $format = shift or die $usage;
    my $inseq = Bio::SeqIO->new(-file   => "<$file",
                                                   -format => $format );
#Arquivo para gravar
my $seq_out = Bio::SeqIO->new('-file' => ">blast4.fasta",
                                       '-format' => fasta);

#Conecta ao banco de dados SQLite
$dbh = DBI->connect("dbi:SQLite:dbname=/home/user/taxonomy/taxonomy.db", "", "",
                    { RaiseError => 1, AutoCommit => 0 });


sub classifica
{
my ($a,$seq) = @_;
my $node = $db->get_Taxonomy_Node(-taxonid => $a);
# Se tem tax id no banco
if ($node)
{
#se  sim 
#print $node->rank,"\t", $node->scientific_name, "\n";
#Marca o primeiro parent_id
$parent = $node->parent_id;
#faz looping até final da classificação
while( (defined $parent) or ($node->rank eq "class"))  {
my $node = $db->get_Taxonomy_Node(-taxonid => $parent);
################################################################################################
#
#                             Procura pelos taxons desejados
#
################################################################################################
if (!$node->rank eq "")
{
if (($node->rank eq "superkingdom") && ($node->scientific_name eq "Bacteria"))
{
#print $node->rank,"\t", $node->scientific_name, "\n";
# grava no texto
$seq_out->write_seq($seq);
###Coloca no array para contagem
push(@in, $node->scientific_name);
} elsif (($node->rank eq "kingdom") && ($node->scientific_name eq "Viridiplantae"))
{
#print $node->rank,"\t", $node->scientific_name, "\n";
# grava no texto
$seq_out->write_seq($seq);
###Coloca no array para contagem
push(@in, $node->scientific_name);
} elsif (($node->rank eq "kingdom") && ($node->scientific_name eq "Fungi"))
{
#print $node->rank,"\t", $node->scientific_name, "\n";
# grava no texto
$seq_out->write_seq($seq);
###Coloca no array para contagem
push(@in, $node->scientific_name);
} elsif (($node->rank eq "superkingdom") && ($node->scientific_name eq "Archaea"))
{
#print $node->rank,"\t", $node->scientific_name, "\n";
# grava no texto
$seq_out->write_seq($seq);
###Coloca no array para contagem
push(@in, $node->scientific_name);
}
}
################################################################################################
#
#                             Final Procura pelos taxons desejados
#
################################################################################################

$parent = $node->parent_id;
} 

#Se não tem no banco de taxid
} else {
print "\nNão TEM\n";
}
}


#variável da barra de progresso
$anda = 1;
$conta = 0;
 while (my $seq = $inseq->next_seq) { #abre loop dentro do arquivo fasta

print ".";
#separa GI
@vai = split('\|+', $seq->id);
#	  print ">",$vai[1],"\n";
#Checa no banco de dados gi2tax e taxonimia
my $all = $dbh->selectall_arrayref("SELECT * FROM gi2tax WHERE gi = $vai[1]");
  foreach my $row (@$all) {
    my ($gi, $taxid) = @$row;
#    print "$gi refere ao taxid $taxid\n";
&classifica($taxid,$seq);
$anda++;
$conta++;
if ($anda eq 51) {
$anda = 1; 
$nova = $conta+1;
print "$conta \n $nova";
}
  }



    } #Fecha loop dentro do arquivo
print "\nTerminado!!!\n";
####### Mostra a contagem 
#################################################################################
#
#                     Gera o array para contagem, coloca os dados no array com o mesmo nome
#
#################################################################################
foreach $names(@in) {
push(@$names, $names);
}

#################################################################################
#
#                     Gera o array unico e faz a contagem
#
#################################################################################

undef %saw;
    @out = grep(!$saw{$_}++, @in);
print "Foram selecionadas: ",scalar(@in)," sequencias\n";
print "Taxa únicos: ",scalar(@out),"\n";
foreach $names(@out) {
print "$names:\t",scalar(@$names),"\n";
}

    exit;

