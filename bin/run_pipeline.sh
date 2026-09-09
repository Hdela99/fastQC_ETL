#!/usr/bin/bash
set -e

# --- Input arguments ---
SRR="$1"
THREADS="${2:-4}"

# --- Set project root (where the pipeline lives) ---
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PROJECT_ROOT

# --- Define paths ---
DATA_DIR="${PROJECT_ROOT}/data/FASTQ/${SRR}"
REPORT_JSON="${DATA_DIR}/fastp_report.json"

echo "========================================"
echo "Starting full pipeline for ${SRR}"
echo "Project root: ${PROJECT_ROOT}"
echo "Using ${THREADS} threads"
echo "========================================"

# --- Step 1: Fetch Metadata (XML) ---
echo "[1/5] Fetching metadata from NCBI..."
bash "${PROJECT_ROOT}/bin/include_metadata.sh" "${SRR}"

# --- Step 2: Extract SRA to FASTQ ---
echo "[2/5] Extracting SRA to FASTQ..."
bash "${PROJECT_ROOT}/bin/extract_sra.sh" "${SRR}" "${THREADS}"

# --- Step 3: Run fastp (trim + QC report) ---
echo "[3/5] Running fastp quality control..."
bash "${PROJECT_ROOT}/bin/run_fastp.sh" "${SRR}" "${THREADS}"

# --- Step 4: Load QC metrics into SQLite ---
echo "[4/5] Loading QC metrics into database..."
python3 "${PROJECT_ROOT}/src/load_qc_into_db.py" "${SRR}" "${REPORT_JSON}"

# --- Step 5: (Optional) Run Kraken2 for viral identification ---
# echo "[5/5] Running Kraken2 taxonomic classification..."
# bash "${PROJECT_ROOT}/bin/run_kraken.sh" "${SRR}" "${THREADS}"

echo "========================================"
echo "Pipeline finished successfully for ${SRR}"
echo "Results are in: ${DATA_DIR}"
echo "QC metrics loaded into: ${PROJECT_ROOT}/db/pipeline_metadata.db"
echo "========================================"