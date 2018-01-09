# BIOSPHA

The term is an acronym of BIOlogical Scripts for PHylogeny Analyses.

It consists of six separated scripts:

BuildDB – This script uses the NCBI taxonomy database to classify and separate sequences from a given a list of FASTA formatted sequences. Any rank parameter from NCBI taxonomy database can be use to filter the desirable sequences.

DUPWIPE – a shell script that uses scripts available at Scriptome to clean duplicate sequence from a file.

SEARCH – Search for a complete taxonomic classification using a GI number, TAXID or scientific name.

FASTAHDR – Using Bioperl components this script rebuild the FASTA sequence header for a more friendly view, enabling custom fields do insert. It also can change the FASTA header for a taxonomic classification.

The last two scripts were intended to build all information necessary for character tracing study using Mesquite (http://mesquiteproject.org/)

BUILDCHAR – using a list of sequences in FASTA format as input, this script taxonomically classify all sequences and use it as character states. It builds the nexus block used as input on mesquite software for simulations of character evolution on a given tree.

BUILDPTP – has the same function of Buildchar, but, it shuffles the characters states n times to build the nexus file used for modified PTP text.

##The scripts

#BIOSPHA - Taxonomy search
TaxSearch is a perl script to search for a complete taxonomic classification using a GI number, TAXID or scientific name.

It runs on a shell and need some additional database to run correctly.

To run TaxSearch:

To search for taxonomy classification of Homo sapiens

LINUX:> perl search.pl -n "homo sapiens"

To search for classification of a GI number you may

LINUX:> perl search.pl -g 220941669 -t -c

The result will be the complete taxonomic classificaton (due to -t option) and the common name list (-c option)

