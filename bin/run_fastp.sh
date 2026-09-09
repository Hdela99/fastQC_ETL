#!/usr/bin/bash
set -e

SRR="$1"
THREADS="${2:-4}"

if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

BASE_DIR="${PROJECT_ROOT}/data/FASTQ/${SRR}"
mkdir -p "$BASE_DIR"

echo "=== Running fastp on ${SRR} ==="

R1="${BASE_DIR}/${SRR}_1.fastq.gz"
R2="${BASE_DIR}/${SRR}_2.fastq.gz"

if [[ -f "$R1" && -f "$R2" ]]; then
    echo "Paired-end mode detected."
    fastp -i "$R1" -I "$R2" \
          -o "${BASE_DIR}/${SRR}_1.trimmed.fastq.gz" \
          -O "${BASE_DIR}/${SRR}_2.trimmed.fastq.gz" \
          -h "${BASE_DIR}/fastp_report.html" \
          -j "${BASE_DIR}/fastp_report.json" \
          --detect_adapter_for_pe
elif [[ -f "$R1" ]]; then
    echo "Single-end mode detected (only R1 found)."
    fastp -i "$R1" \
          -o "${BASE_DIR}/${SRR}_1.trimmed.fastq.gz" \
          -h "${BASE_DIR}/fastp_report.html" \
          -j "${BASE_DIR}/fastp_report.json"
else
    echo "ERROR: No FASTQ files found for ${SRR} in $BASE_DIR"
    exit 1
fi

echo "=== fastp finished for ${SRR} ==="