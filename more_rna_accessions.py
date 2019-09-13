#!/usr/local/bin/python3

import argparse
import xml.etree.ElementTree as ET

parser = argparse.ArgumentParser(description="Generate a list of SRA experiments which haven't been run before.")
parser.add_argument('--num-experiments', type=int, help='Number of experiments to output.')
parser.add_argument('--percent-experiments', type=int, help='Percentage of all experiments to output.')
parser.add_argument('--xml-file', type=str, help='XML file to pull SRA experiments from.')
parser.add_argument('--exclude-list', type=str, help='A file with one accesion per line which should be excluded from the output.')

args = parser.parse_args()

if not args.xml_file:
    print("Must specify --xml-file.")

# if not args.num_experiments and not args.percent_experiments or\
#    (args.num_experiments and args.percent_experiments):
#     print("Must specify one of --num-experiments or --percent-experiments, but not both.")


xml_root = ET.parse(args.xml_file).getroot()

study_accessions = set()
for study in xml_root:
    for identifiers in study.findall("IDENTIFIERS"):
        for child in identifiers:
            if str.startswith(child.text, "DRP") \
               or str.startswith(child.text, "ERP") \
               or str.startswith(child.text, "SRP"):
                study_accessions.add(child.text)


if args.percent_experiments:
    num_experiments = len(study_accessions) * args.percent_experiments
else:
    num_experiments = args.num_experiments

if args.exclude_list:
    with open(args.exclude_list) as exclude_list_file:
        exclude_list = exclude_list_file.readlines()

previous_accessions = set()
for accession in exclude_list:
    previous_accessions.add(accession.strip())

new_accessions = study_accessions - previous_accessions

with open("new_accessions.txt", "w") as output_file:
    for accession in list(new_accessions)[0:num_experiments]:
        output_file.write(accession + "\n")
