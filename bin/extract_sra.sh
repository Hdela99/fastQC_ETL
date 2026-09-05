#!/usr/bin/bash
set -e

OUT_DIR ="../data/FASTQ/${1}"
TMP_DIR ="../tmp"
mkdir -p "$OUT_DIR"
mkdir -p "$TMP_DIR"

echo "=== testing SRA Data Extraction ==="

echo "[1/4] Prefetching SRA file..."
prefetch "${1}"

echo "[2/4] Running fasterq-dump..."
fasterq-dump "${1}" \
    --outdir "$OUT_DIR" \
    --tmpdir "$TMP_DIR" \
    --threads "$THREADS" \
    --split-files \
    --progress

echo "[3/4] Compression time..."
pigz -p "$THREADS" "$OUT_DIR/${1}"*.fastq

echo "[4/4] Cleaning up.."
rm -rf "{1}"

echo "Finished processing ${1}."
