# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

genomefile="$1"

echo "Indexing, please wait."

indexdir="$2"

STAR --runThreadN 4 --runMode genomeGenerate --genomeDir {$indexdir} \
--genomeFastaFiles {$genomefile} --genomeSAindexNbases 9

# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.

# STAR --runThreadN 4 --runMode genomeGenerate --genomeDir <outdir> \
# --genomeFastaFiles <genomefile> --genomeSAindexNbases 9
