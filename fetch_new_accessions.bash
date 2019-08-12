#!/bin/bash
# Download information on all of the taxon ids in ACCESSION_LIST, and concatenate all new accessions

ACCESSION_LIST="$1"
OUTPUT_FILE="$2"

if [ $# -lt 2 ]; then
	echo "Error: 2 arguments are required" >&2
	exit 1
fi

shift
shift

while getopts "r" opt; do
	case $opt in
		r)
			REFRESH=true
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
	esac
done

if ! [ "$UPDATE" ]; then
	UPDATE=false
fi

# Initialize variables
count=0
total="$(wc -l "$ACCESSION_LIST" | awk '{ print $1 }')"

# Empty all_new_accessions.txt
printf "" > "$OUTPUT_FILE"

# Download information for each taxon_id, then add new accessions to all_new_accessions.txt
while read -r taxon_id; do
    count=$(( count + 1 ))
    echo "Processing taxon id $taxon_id, $count out of $total"
    mkdir -p "downloaded_data/$taxon_id"
    pushd "downloaded_data/$taxon_id" > /dev/null || exit

    formatted_query="$(python3 ../../format_query.py "$taxon_id")"
    formatted_data="result=READ_STUDY&query=${formatted_query}&display=xml"

    if $UPDATE || [ ! -e data.xml ]; then
    	curl 'https://www.ebi.ac.uk/ena/data/warehouse/search' --data "$formatted_data" --compressed > data.xml
    fi
    # Yes, I'm sure we want to glob here
    # shellcheck disable=2086
    ../../more_rna_accessions.py --num-experiments=200 --xml-file=data.xml\
				 --exclude-list=<(cat ../../previous_accessions/**/*${taxon_id}.txt 2>/dev/null)

    # Sort new_accessions.txt so that the file is deterministic. Otherwise, every time more_rna_accessions.py runs,
    # it results in a different order, making git track more changes than it needs to
    sort -o new_accessions.txt new_accessions.txt

    cat new_accessions.txt >> ../../"$OUTPUT_FILE"

    popd > /dev/null || exit
done < "$ACCESSION_LIST"

echo "All new accessions written to $OUTPUT_FILE"

# https://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script
# read -p "Would you like to mark the downloaded accessions as previous accessions? [y/N] " -n 1 -r
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#     timestamp="$(date +%F,%X)"
#     previous_accession_directory="previous_accessions/$timestamp"
#     mkdir "$previous_accession_directory" || exit
#     for file in downloaded_data/*; do
# 	cp "$file/new_accessions.txt" "$previous_accession_directory/$(basename "$file").txt"
#     done
# fi
