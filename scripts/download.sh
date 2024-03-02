# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes" 
url="$1"
tgt_dir="$2"
uncompress="$3"

filename="$(basename "$url")"

tgt_dir="./$tgt_dir"

if wget -O "$tgt_dir/$filename" "$url"; then
    echo "Se ha descargado $tgt_dir/$filename"
else
    echo "Error al descargar $url"
    exit 1
fi

if [ "$uncompress" = "yes" ]; then
    echo "Descomprimiendo $tgt_dir/$filename"
    gunzip "$tgt_dir/$filename" || exit 1
else
    echo "El archivo ya esta descomprimido"
fi

# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output
