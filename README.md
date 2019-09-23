# README

A repository for scripts related to filling expungement and sealing case charts used by Cabrini Green Legal Aid in Illinois.

Currently, one script exists, `script.rb`, that fills case charts using CSV files produced by the Champaign County Clerk.

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

These scripts also require [PDFTK](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) to be installed on your machine.

## Run

```
$ ./script.rb [path_to_directory_holding_csv_files]
```

The script will generate filled case chart PDFs for each CSV file in the directory, and save them in the `output/` folder of this project. One case chart PDF is created for every 10 court events in a given input file.

The script uses the name of the input file to construct the output file name. If the input file name is JONES.csv, the output file names will be JONES_case_chart_0.pdf, JONES_case_chart_1.pdf, etc.