echo "Downloading databases from NCBI";
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/gi_taxid_prot.zip
wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/gi_taxid_nucl.zip

echo "Backuping the old database";
if [ -f  'taxonomy.db' ];
then
echo "backup taxonomy database";
mv taxonomy.db taxonomy_old.db
fi

if [ -f  "names.dmp" ];
then
rm -f names.dmp
fi

if [ -f  'nodes.dmp' ];
then
rm -f nodes.dmp
fi

if [ -d 'idx' ]; then
    rm -r idx/
fi

if [ ! -d 'idx' ]; then
    mkdir idx
fi

echo "Extract fles";
tar -zxvf taxdump.tar.gz names.dmp nodes.dmp
unzip gi_taxid_prot.zip
unzip gi_taxid_nucl.zip

echo "Treating file for import";
perl -e ' $sep="\t|\t";  while(<>) { s/\Q$sep\E/\t/g; print $_; } warn "Changed $sep to tab on $. lines\n" ' nodes.dmp > nodes.csv  
perl -e ' @cols=(0, 1, 2);  while(<>) { s/\r?\n//; @F=split /\t/, $_; print join("\t", @F[@cols]), "\n" } warn "\nChose columns ", join(", ", @cols), " for $. lines\n\n" ' nodes.csv > nodes_import.dat
perl -e ' $sep="\t|\t";  while(<>) { s/\Q$sep\E/\t/g; print $_; } warn "Changed $sep to tab on $. lines\n" ' names.dmp > names.csv  
perl -e ' @cols=(0, 1, 3);  while(<>) { s/\r?\n//; @F=split /\t/, $_; print join("\t", @F[@cols]), "\n" } warn "\nChose columns ", join(", ", @cols), " for $. lines\n\n" ' names.csv > names_import.dat

echo "Creating SQLite database";
sqlite3 taxonomy.db "CREATE TABLE nodes (taxid int, parent_taxid int, rank text)";
sqlite3 taxonomy.db "CREATE TABLE names (taxid int, name_txt text, name_unique text)";
sqlite3 taxonomy.db "CREATE TABLE gi2tax (gi int, taxid int)";
echo "Importing data";
echo .separator \"\\t\" >> commands
echo .import names_import.dat names >> commands
echo .import nodes_import.dat nodes  >> commands
echo .import gi_taxid_prot.dmp gi2tax >> commands
echo .import gi_taxid_nucl.dmp gi2tax >> commands
sqlite3 taxonomy.db < commands
sqlite3 taxonomy.db 'delete from names where name_unique <> "scientific name"';

echo "Creating indexes";
sqlite3 taxonomy.db "CREATE INDEX node_taxid on nodes (taxid)";
sqlite3 taxonomy.db "CREATE INDEX name_taxid on names (taxid)";
sqlite3 taxonomy.db "CREATE INDEX gi on gi2tax (gi)";

echo "Cleaning the mess";
rm -f gc.prt names.csv names_import.dat nodes.csv nodes_import.dat commands gi_taxid_prot.dmp gi_taxid_nucl.dmp

echo "Done!"

