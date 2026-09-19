import sqlite3
import os
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

    rows_to_insert = []

    with open(kraken_report, newline='') as handle:
        reader = csv.reader(handle, delimiter='\t')
        for row in reader:
            abundance = float(row[0])
            read_count = int(row[2])
            rank = row[3]
            tax_id = int(row[4])
            name = row[5].strip()
            #TODO add a filter for the virus
            rows_to_insert.append((srr_id, tax_id, name, rank, abundance, read_count, "kraken2"))
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.executemany("""INSERT INTO taxonomic_abundance (
    srr_id, tax_id, name, rank, abundance, read_count, tool
    ) VALUES (?, ?, ?, ?, ?, ?, ?)""", rows_to_insert)
    conn.commit()
    conn.close()
    print(f"Taxonomic abundance for {srr_id} loaded into {db_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python load_taxonomy_into_db.py <SRR_ID> <kraken_report>")
        sys.exit(1)
    srr_id = sys.argv[1]
    kraken_path = sys.argv[2]

    project_root = os.environ.get('PROJECT_ROOT')
    if not project_root:
        project_root = str(Path(__file__).parent.parent)

    db_path = Path(project_root) / "db" / "pipeline_metadata.db"

    #create tables if they dont exist

    schema_file = Path(project_root) / "src" / "schema.sql"

    if schema_file.exists():
        with open(schema_file, 'r') as f:
            schema_sql = f.read()
        conn = sqlite3.connect(db_path)
        conn.executescript(schema_sql)
        conn.close()
    else:
        print(f"Warning: schema.sql not found at {schema_file}")
    load_taxonomy_info(srr_id, kraken_path, str(db_path))





