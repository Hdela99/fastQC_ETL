#!/usr/bin/env python3
import sqlite3
import json
import sys
import os
from pathlib import Path

def load_qc_metrics(srr_id, fastp_json_path, db_path):
    """Extract QC metrics from fastp JSON and insert into SQLite."""
    
    # Read JSON
    with open(fastp_json_path, 'r') as f:
        data = json.load(f)
    
    before = data['summary']['before_filtering']
    after = data['summary']['after_filtering']
    
    # Calculate passed filter %
    passed_pct = (after['total_reads'] / before['total_reads']) * 100
    
    # Get file paths
    out_dir = Path(fastp_json_path).parent
    r1_trimmed = out_dir / f"{srr_id}_1.trimmed.fastq.gz"
    r2_trimmed = out_dir / f"{srr_id}_2.trimmed.fastq.gz"
    
    # Connect and insert
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Insert or update QC metrics
    cursor.execute("""
        INSERT OR REPLACE INTO qc_metrics (
            srr_id,
            total_reads_before,
            total_reads_after,
            q30_rate_before,
            q20_rate_before,
            gc_content_before,
            gc_content_after,
            passed_filter_pct,
            mean_length_before_r1,
            mean_length_before_r2,
            mean_length_after_r1,
            mean_length_after_r2,
            duplication_rate,
            fastp_report_path,
            trimmed_fastq_r1_path,
            trimmed_fastq_r2_path
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        srr_id,
        before['total_reads'],
        after['total_reads'],
        before['q30_rate'],
        before['q20_rate'],
        before['gc_content'],
        after['gc_content'],
        passed_pct,
        before.get('read1_mean_length', 0),
        before.get('read2_mean_length', 0),
        after.get('read1_mean_length', 0),
        after.get('read2_mean_length', 0),
        data['summary'].get('duplication_rate', 0.0),
        fastp_json_path,
        str(r1_trimmed),
        str(r2_trimmed)
    ))
    
    conn.commit()
    conn.close()
    print(f"✅ QC metrics for {srr_id} loaded into {db_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python load_qc_into_db.py <SRR_ID> <path_to_fastp_report.json>")
        sys.exit(1)
    
    srr_id = sys.argv[1]
    json_path = sys.argv[2]
    
    # Get project root from environment, or compute from script location
    project_root = os.environ.get('PROJECT_ROOT')
    if not project_root:
        # Assume script is in src/ inside project root
        project_root = str(Path(__file__).parent.parent)
    
    db_path = Path(project_root) / "db" / "pipeline_metadata.db"
    
    # Create tables if not exist (using schema.sql)
    schema_file = Path(project_root) / "src" / "schema.sql"
    if schema_file.exists():
        with open(schema_file, 'r') as f:
            schema_sql = f.read()
        conn = sqlite3.connect(db_path)
        conn.executescript(schema_sql)
        conn.close()
    else:
        print(f"Warning: schema.sql not found at {schema_file}")
    
    load_qc_metrics(srr_id, json_path, str(db_path))