
# Workflow

build_db.py creates an sqlite3 database, inserts the tickets data as a table, and extracts observables from the tickets, creating a new observables table.

similarities.py creates new tables of non-zero similarities between observables (based on co-membership in tickets) and between tickets (based on co-mentions of observables)

process_data/* loads the database into R and creates static fiels that the app will use for fast retrieval
