#!/usr/bin/bash
set -e
SRR="$1"
THREADS="${2:-4}"
OUT_DIR="../data/FASTQ/${SRR}"
TMP_DIR="../tmp"
mkdir -p "$OUT_DIR"
mkdir -p "$TMP_DIR"

echo "=== testing SRA Data Extraction ==="

echo "[1/4] Prefetching SRA file..."
prefetch "${SRR}"

echo "[2/4] Running fasterq-dump..."
fasterq-dump "${SRR}" \
    --outdir "$OUT_DIR" \
    --temp "$TMP_DIR" \
    --threads "$THREADS" \
    --split-files \
    --progress

echo "[3/4] Compression time..."
pigz -p "$THREADS" "$OUT_DIR/${SRR}"*.fastq

echo "[4/4] Cleaning up.."
rm -f "$TMP_DIR"/*.tmp 2>/dev/null || true
rm -f "${SRR}" 2>/dev/null || true
#rm -rf "{1}"

echo "Finished processing ${SRR}."
