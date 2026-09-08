#!/usr/bin/bash
set -e

SRR="$1"
OUT_DIR="../data/metadata/${SRR}"
mkdir -p "$OUT_DIR"

echo "=== pulling metadata as xml file for ${SRR} ==="

esearch -db sra -query "${SRR}" | efetch -format native -mode xml > "${OUT_DIR}/${SRR}_metadata.xml"

# Check that the file was created and has content
if [ ! -s "${OUT_DIR}/${SRR}_metadata.xml" ]; then
    echo "ERROR: metadata download failed or file is empty."
    exit 1
fi

echo "Metadata saved to ${OUT_DIR}/${SRR}_metadata.xml"