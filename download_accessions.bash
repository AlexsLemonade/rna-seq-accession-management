#!/bin/bash
# Download information on all of the taxon ids in ACCESSION_LIST, and concatenate all new accessions

ACCESSION_LIST="$1"

if [ -e downloaded_data ]; then
	rm -rf downloaded_data
fi
mkdir downloaded_data

# Initialize variables
count=0
total="$(wc -l "$ACCESSION_LIST" | awk '{ print $1 }')"

# Empty all_new_accessions.txt
printf "" > all_new_accessions.txt

# Download information for each taxon_id, then add new accessions to all_new_accessions.txt
while read -r taxon_id; do
    count=$(( count + 1 ))
    echo "Processing taxon id $taxon_id, $count out of $total"
    mkdir -p "downloaded_data/$taxon_id"
    cd "downloaded_data/$taxon_id" || exit

    formatted_query="$(python ../../format_query.py "$taxon_id")"
    formatted_data="result=READ_STUDY&query=${formatted_query}&display=xml"
    curl 'https://www.ebi.ac.uk/ena/data/warehouse/search' --data "$formatted_data" --compressed > data.xml
    # Yes, I'm sure we want to glob here
    # shellcheck disable=2086
    ../../more_rna_accessions.py --percent-experiments=1 --xml-file=data.xml\
				 --exclude-list=<(cat ../../previous_accessions/**/*${taxon_id}.txt 2>/dev/null)

    cat new_accessions.txt >> ../../all_new_accessions.txt

    cd ../.. || exit
done < "$ACCESSION_LIST"

# https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script
read -p "Would you like to mark the downloaded accessions as previous accessions? [y/N] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    timestamp="$(date +%F,%X)"
    previous_accession_directory="previous_accessions/$timestamp"
    mkdir "$previous_accession_directory" || exit
    for file in downloaded_data/*; do
	cp "$file/new_accessions.txt" "$previous_accession_directory/$(basename "$file").txt"
    done
fi
