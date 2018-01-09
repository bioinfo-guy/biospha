#!/usr/bin/perl
use DBI;
use Data::Dumper;
use Getopt::Long;
    $result = GetOptions ("gi=s"   => \$querygi,      # string
			"name=s"  => \$queryname,
			"common"  => \$common,
			"taxonomy" => \$taxonomy);  # flag
#checa se todos os parâmetros necessários para este script estão corretos
if (!($querygi or $queryname)) {
die("\n\nERROR 001\nYou must supply a query string\nTry taxid -h for help on how to use this script\n\n\n");
}
if ($queryname ne "" && ($querygi ne "" or $common ne "" or $taxonomy ne "")) {
die ("\n\nERROR 002\nThe option -n or -name can only be used alone\n");
}
if ($querygi =~ /[a-zA-Z]/) {
die ("\n\nERROR 003\nYou try to search for a GI using an alphabetic query.\nFor species names use option -n\n\n\n");
}
if ($queryname =~ /[0-9]/) {
die ("\n\nERROR 004\nYou try to search for a name using an numeric query.\nFor GI use option -g\n\n\n");
}

#Conecta ao banco de dados SQLite
$dbh = DBI->connect("dbi:SQLite:dbname=/home/user/taxonomy/taxonomy2.db", "", "
",
                    { RaiseError => 1, AutoCommit => 0 });

#checa a primeira classificação, fazendo busca pelo GI
if ($querygi =~ /[0-9]/) {
my $all = $dbh->selectall_arrayref("SELECT * FROM gi2tax WHERE gi2tax.gi = $querygi")
    or die "print não existe este";
foreach my $row (@$all) {
      my ($gi,  $taxid) = @$row;
    print "The GI $gi refers to the taxid $taxid\nTo further information use options -c for commom names and/or -t for taxonomic classification.\n\n";
    $parent = $taxid;
}
}

#checa a primeira classificação, fazendo busca pelo nome
if ($queryname =~ m/[a-zA-Z]/) {
my $all = $dbh->selectall_arrayref("SELECT * FROM names WHERE name_txt LIKE '$queryname'")
    or die "print não existe este";
foreach my $row (@$all) {

      my ($taxid, $name_txt, $name_unique) = @$row;
    print "\U$name_unique\t\t $name_txt ($taxid)\n";
    $parent = $taxid;
}
}

#Checa nomes alternativos
if ($common) {
print "\nNOMES COMUNS\n\n";
my $all = $dbh->selectall_arrayref("SELECT * FROM names, nodes WHERE nodes.taxid = $parent AND names.taxid = nodes.taxid")
    or die "print não existe este";
#If array is not empty show results
if (@all) {
print "fudeu!";
}
foreach my $row (@$all) {
      my ($taxid,  $name_txt,  $name_unique,  $taxid,  $parent_taxid,  $rank) = @$row;
    print "\U$name_unique\E\t\t\u$name_txt\E\n";
}
}

if ($taxonomy) {
print "\n\nCLASSIFICAÇÃO\n\n";
if (($parent eq "") ||  ($parent eq "0")){
print "\n\nSua busca por $query não retornou resultado válido, tente novamente\n\n\n";
} else {
#faz a busca no banco de dados pelo resto da classificação
$stop = 0;
until($stop eq 1)  {
my $all = $dbh->selectall_arrayref("SELECT * FROM names, nodes WHERE nodes.taxid = $parent AND names.taxid = nodes.taxid AND names.name_unique = 'scientific name'")
   or die "print não existe este";

foreach my $row (@$all) {
      my ($taxid,  $name_txt,  $name_unique,  $taxid,  $parent_taxid,  $rank) = @$row;
    print "$rank\t\t$name_txt\t($taxid)\n";
$parent = $parent_taxid;
if ($taxid eq 1) {
print $stop = 1;}
 #fecha erro!
}
} 
} #if
} #fecha $taxonomy
$dbh->disconnect();