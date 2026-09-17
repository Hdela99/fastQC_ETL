import sqlite3
import json
import sys
import os
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
'''
def load_taxonomy_info(srr_id, kraken_report, db_path):
    """Extract top X ranking taxonomy reports"""
    # Read text file

    with open(kraken_report, 'r', encoding="utf-8") as f:
        data = f.read()
