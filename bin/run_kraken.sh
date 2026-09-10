#!/usr/bin/bash

set -e

SRR="$1"
THREADS="${2:-4}"

if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

KRAKEN_DB="${PROJECT_ROOT}/db/kraken2/minikraken_8GB_20200312"
TRIMMED_R1="${PROJECT_ROOT}/data/FASTQ/${SRR}/${SRR}_1.trimmed.fastq.gz"
TRIMMED_R2="${PROJECT_ROOT}/data/FASTQ/${SRR}/${SRR}_2.trimmed.fastq.gz"

echo "=== Running Kraken2 on ${SRR} === "
if [[ -f "$TRIMMED_R1" && -f "$TRIMMED_R2" ]]; then
    echo "Paired end mode detected."
    kraken2 --db "${KRAKEN_DB}" \
            --paired "${TRIMMED_R1}" "${TRIMMED_R2}" \
            --threads "${THREADS}" \
            --output "${PROJECT_ROOT}/data/FASTQ/${SRR}/kraken_output.txt" \
            --report "${PROJECT_ROOT}/data/FASTQ/${SRR}/kraken_report.txt"
elif [[ -f "$TRIMMED_R1" ]]; then
    echo "Single-end mode detected"
    kraken2 --db "${KRAKEN_DB}" \
            --threads "${THREADS}" \
            --output "${PROJECT_ROOT}/data/FASTQ/${SRR}/kraken_output.txt" \
            --report "${PROJECT_ROOT}/data/FASTQ/${SRR}/kraken_report.txt" \
            "${TRIMMED_R1}"
else
    echo "ERROR: Something went wrong, you entered ${SRR}."
    exit 1
fi

echo "=== kraken2 finished for ${SRR} ==="
