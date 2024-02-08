# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).
input_dir="$1"
output_dir="$2"
sample_id="$3"

output_file="${output_dir}/${sample_id}.fastq.gz"

echo: "Ficheros a procesar"
ls -l "${input_dir}/${sample_id}.5dpp.1.1s_sRNA.fastq" "${input_dir}/${sample_id}.5dpp.1.2s_sRNA.fastq"

echo "Ficheros listos"
echo "${output_file}"

cat "${input_dir}/${sample_id}.5dpp.1.1s_sRNA.fastq" "${input_dir}/${sample_id}.5dpp.1.2s_sRNA.fastq" > "${output_file}"
echo "Files merged into ${output_file}"