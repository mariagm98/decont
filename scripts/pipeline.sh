urls=( 
    "https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.1s_sRNA.fastq.gz"
    "https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.2s_sRNA.fastq.gz" 
    "https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.1s_sRNA.fastq.gz"
    "https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.2s_sRNA.fastq.gz"
    )

for url in ${urls[@]} #TODO
do
    bash scripts/download.sh "$url" data
done

# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs

contaminants_url="https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz"

if [ ! -e "res/contaminants.fasta" ]; then
    bash scripts/download.sh "$contaminants_url" res yes
else 
    echo "The contaminants database is ready. Indexing..."
fi
if [ ! -d "res/contaminants_index/" ]; then
    mkdir -p "res/contaminants_index"
fi

if [ ! -n "$(ls -A res/contaminants_index/ )" ]; then
    bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
else
    echo "Contaminants are already indexed."
fi

# Merge the samples into a single file

if [ ! -d "out/merged" ] ; then
    mkdir -p "out/merged"
fi

echo "Merging..."
if [ ! -n "$(ls -A out/merged/ )" ]; then
    for sample_id in $(ls data/*.fastq.gz |cut -d "." -f1 | sed 's:data/::' | sort |uniq); do
        bash scripts/merge_fastqs.sh data out/merged $sample_id
    done
else
    echo "Files already merged. SKipping merging"
fi

#run cutadapt for all merged files
if [ ! -d "log/cutadapt" ]; then
        mkdir -p "log/cutadapt"
fi

if [ ! -d "out/trimmed" ]; then 
        mkdir -p "out/trimmed"
fi
#Si ya hemos eliminado los adaptadores, nos saltamos este paso.
echo "Trimming adapters..."
if [ -z "$(ls -A log/cutadapt/ )" ]
then
        for filename in $(ls out/merged/*.fastq.gz | xargs -n 1 basename)
        do
                echo "Before cutadapt: $filename"
                cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
                        -o out/trimmed/"$filename".trimmed.fastq.gz  out/merged/"$filename" > log/cutadapt/"$filename".log >> log/pipeline.log 2>&1
                echo "After cutadapt: $filename"        
done

else
        echo "Skipping cutadapt."

fi

#Run STAR for all trimmed files. Comprobamos si existe el directorio, y si no, lo creamos.

if [ ! -d "out/star" ]; then
        mkdir -p "out/star"
fi


echo "Running STAR..."
if [ -n "find out/trimmed -type f -name '*.fastq.gz')" ]
then 
        for fname in out/trimmed/*.fastq.gz
        do
                sampleid=$(basename "$fname" .trimmed.fastq.gz | cut -d "." -f1 | cut -d "-" -f1)
		echo "$sampleid"
                if [ ! -d "out/star/$sampleid" ]
                then
                        mkdir -p "out/star/$sampleid"
                fi

                STAR --runThreadN 4 --genomeDir res/contaminants_index \
                      --outReadsUnmapped Fastx --readFilesIn "$fname" \
                      --readFilesCommand gunzip -c --outFileNamePrefix out/star/"$sampleid"/ >> log/pipeline.log 2>&1
        done

else
        echo "No files found in out/trimmed. Skipping STAR."
fi


# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in
#