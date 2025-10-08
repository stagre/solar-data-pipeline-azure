# Example Solar CSV Format
This is a example file based on real solar production data, anonymized and trimmed.
The (currently) static data set contains one report per day in CSV format. Files will be aggregated. 

### Sample columns:
- `Plant name`: e.g. "Plant 1", "Plant 2"
- `Time`: Timestamp in 5-minute intervals (local time)
- `Real-time power (kW)`: Instantaneous production
- `Installed Power (kWp)`: Static capacity (i.e 10.0 kWp)
- Other columns currently unused or missing (will be filtered or ignored in transformations)