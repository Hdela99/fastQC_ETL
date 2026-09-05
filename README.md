This will be my attempt at making a basic low level ETL pipeline that will extract data from public ncbi repositories via SRR IDs, do low level analysis and transform the data into a format that is compatible for loading into my sqlite3 database. Projected timeline and basic explanation is below:


Extract
  NCBI SRA accession / metadata
  → local SRA object
  → paired FASTQ files

Transform
  → validate read structure
  → compute small QC summaries
  → derive records suitable for a database

Load
  → write run/sample/QC records
  → query those records to confirm the load