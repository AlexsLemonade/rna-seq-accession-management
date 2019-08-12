#!/usr/bin/python3

import sys
from urllib.parse import quote_plus

URL_FORMAT_STRING = 'tax_eq({}) ' + \
    'AND ' + \
    '(' + \
    'instrument_model="HiSeq X Ten" ' + \
    'OR instrument_model="HiSeq X Five" ' + \
    'OR instrument_model="Illumina MiSeq" ' + \
    'OR instrument_model="Illumina NovaSeq 6000" ' + \
    'OR instrument_model="Illumina Genome Analyzer" ' + \
    'OR instrument_model="Illumina Genome Analyzer II" ' + \
    'OR instrument_model="Illumina Genome Analyzer IIx" ' + \
    'OR instrument_model="Illumina HiScanSQ" ' + \
    'OR instrument_model="Illumina HiSeq 1000" ' + \
    'OR instrument_model="Illumina HiSeq 1500" ' + \
    'OR instrument_model="Illumina HiSeq 2000" ' + \
    'OR instrument_model="Illumina HiSeq 2500" ' + \
    'OR instrument_model="Illumina HiSeq 3000" ' + \
    'OR instrument_model="Illumina HiSeq 4000" ' + \
    'OR instrument_model="NextSeq 500" ' + \
    'OR instrument_model="NextSeq 550" ' + \
    'OR instrument_model="Ion Torrent Proton" ' + \
    'OR instrument_model="Ion Torrent S5" ' + \
    'OR instrument_model="Ion Torrent S5 XL"' + \
    ')' + \
    'AND library_strategy="RNA-Seq" ' + \
    'AND library_source="TRANSCRIPTOMIC"'\

print(quote_plus(URL_FORMAT_STRING.format(sys.argv[1])))
