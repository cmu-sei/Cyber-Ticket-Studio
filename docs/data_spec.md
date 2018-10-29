# How to prepare data to for the app

## Fake example data

From inside the `/data` directory, run `Rscript make_example_data.R` to generate "tickets.csv", automatically saving this in the data directory specified in `~/.cyber_ticket_studio`.

## Real data

Any real data must conform to exactly the same format as the fake example data above.  This includes having 

- the same file name ("tickets.csv"), 
- the same set of columns (although having extra columns does not necessarily cause the app to crash) 
- and having the same format for each column.

Coming soon: an example script for preparing a real publically available data set. 

