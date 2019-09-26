# README

A repository for scripts related to filling expungement and sealing case charts used by Cabrini Green Legal Aid in Illinois.

There are currently two scripts that fill case charts using CSV files produced by the Champaign County Clerk. 


## Install

First, clone the repo via git:

```
$ git clone git@github.com:codeforamerica/cgla_case_chart_filler.git
```

And then install the dependencies with Bundler

```
$ cd cgla_case_chart_filler
$ bundle install
```

Some scripts also require [PDFTK](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) to be installed on your machine.

## Run

```
$ ./[script_name] [path_to_directory_holding_csv_files]
```
`fill_csv.rb` creates a new CSV file in `output/csv` with the eligibility, conviction, waiting period, and notes columns populated.

`fill_pdf.rb` fills two versions of a PDF case chart, one version with only basic charge information in `output/pdf/basic_info` and the other with eligibility determinations on `output/pdf/with_eligibility`.

The script uses the name of the input file to construct the output file name. If the input file name is JONES.csv, the output file name will be JONES_case_chart.csv.
#### The `fill_pdf.rb` script is currently deprecated for Champaign County 
