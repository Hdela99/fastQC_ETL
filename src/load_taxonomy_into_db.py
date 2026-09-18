import sqlite3
import json
import sys
import csv
from pathlib import Path
'''
CREATE TABLE IF NOT EXISTS taxonomic_abundance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    srr_id TEXT NOT NULL,
    tax_id INTEGER,
    name TEXT,
    rank TEXT,
    abundance REAL,
    read_count INTEGER,
    tool TEXT,
    FOREIGN KEY (srr_id) REFERENCES runs(srr_id)
);
columns of the kraken_report.txt
1: % of reads covered by clade
2: # of reads covered by clade including descendants.
3: # of reads assigned to that clade excluding descendants.
4: Taxonomic rank code:
    U: Unclassified
    R: Root
    D: Domain
    K: Kingdom
    P: Phylum
    C: Class
    O: Order
    F: Family
    G: Genus
    S: Species
5: NCBI Taxonomic ID num
6: Scientific name.

We want to:
Extract-> Open report, iterate line by line parsing each line into the 6 tab separated fields. 
Transform-> Convert % to floats, Converts counts and Taxonomic ID to ints, Remove spaces before scientific name, then we decide which records to keep.
Load-> Open sqlite3, insert cleaned records w/ parameterized query, commit after insertion and close connection. 
'''
def load_taxonomy_info(srr_id, kraken_report, db_path):
    """Extract top X ranking taxonomy reports"""
    # Read text file

    with open(kraken_report, encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, start=1):
            print(line_number, repr(line))
