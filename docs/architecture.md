# Architecture Overview (Initial Draft)
A rough sketch of how the first iteration of the pipeline will work.

## Goal
Ingest static CSV files with solar production data, transform the data to a clean format, and create a basic Power BI dashboard.

## Architecture (v0)

1. **Storage**: Azure Data Lake Storage Gen2  
    - Container for raw CSV files

2. **Ingestion**: Azure Data Factory (ADF)  
    - Copy activity to move data into a structured location
    - Evt. explore later: SQL transformation or Data Flows

3. **Exploration and Transformation**:  
    - Python and ADF Data Flows
    - Evt. explore later: Azure SQL or Spark

4. **Output Layer**:  
   - Clean data stored as Parquet or CSV  
   - Possibly a SQL sink for easier dashboard access

5. **Visualization**: Power BI Desktop  
   - Connects to the cleaned data
