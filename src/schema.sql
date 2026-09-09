-- schema.sql
-- Run this once to initialize the database

CREATE TABLE IF NOT EXISTS runs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    srr_id TEXT UNIQUE NOT NULL,
    sample_name TEXT,
    collection_date TEXT,
    host TEXT,
    tissue_type TEXT,
    library_strategy TEXT
);

CREATE TABLE IF NOT EXISTS qc_metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    srr_id TEXT NOT NULL,
    total_reads_before INTEGER,
    total_reads_after INTEGER,
    q30_rate_before REAL,
    q20_rate_before REAL,
    gc_content_before REAL,
    gc_content_after REAL,
    passed_filter_pct REAL,
    mean_length_before_r1 INTEGER,
    mean_length_before_r2 INTEGER,
    mean_length_after_r1 INTEGER,
    mean_length_after_r2 INTEGER,
    duplication_rate REAL,
    fastp_report_path TEXT,
    trimmed_fastq_r1_path TEXT,
    trimmed_fastq_r2_path TEXT,
    FOREIGN KEY (srr_id) REFERENCES runs(srr_id)
);

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