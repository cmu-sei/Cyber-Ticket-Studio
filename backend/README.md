# Notes

`build_backend.sh` is a shell script that prepares the data for visualization in CTS by executing both of the following scripts:

- `_python_build_step_1.py` creates an sqlite3 database, inserts the tickets data as a table, extracts observables from the tickets to create a new observables table, and generates a sparse table of similarities among the observables.
- `_R_build_step_2.R` caches numerous views of the sqlite database as R-ready binaries for fast retrieval in CTS.
