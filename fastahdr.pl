#!/usr/bin/perl -w
    use DBI;
    use Bio::SeqIO;
    use Data::Dumper;
    use Bio::DB::Taxonomy;
    my $usage = "rebuildfasta.pl infile > outfile \n";
    my $file = shift or die $usage;
    #my $outfile = shift or die $usage;
    my $inseq = Bio::SeqIO->new(-file   => "<$file",
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

#Rotina de busca dentro da lista ge taxid
sub classifica
{
my ($a) = @_;
my $node = $db->get_Taxonomy_Node(-taxonid => $a);
#marca especie
if ($node->rank eq "species") {
$especie = $node->scientific_name;
}
#Marca o primeiro parent_id
$parent = $node->parent_id;
#faz looping até final da classificação
while( (defined $parent))  {
my $node = $db->get_Taxonomy_Node(-taxonid => $parent);
if ($node->rank eq "genus") {
$genero = $node->scientific_name;
}
if ($node->rank eq "phylum") {
$filo = $node->scientific_name;
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
	  
#array
push(@in, $especie);	  
print ">",$genero,"_",$class,"_",$filo,"_",$separa[1],"\n";
          print $seq->seq,"\n";
    } #Fecha loop dentro do arquivo

#array
undef %saw;
    @out = grep(!$saw{$_}++, @in);
print "Array original: ",scalar(@in),"\n";
print "Array filtrado: ",scalar(@out),"\n";
foreach $i (@out) {
    print "\U$i\E\n";
}    

exit;
