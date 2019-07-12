#!/bin/bash
# Fetch all new accessions using the download_accessions.bash script

./fetch_new_accessions.bash taxon_ids.txt all_new_accessions.txt "$@"
