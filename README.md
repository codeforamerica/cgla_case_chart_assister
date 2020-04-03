# README

A repository for scripts related to filling expungement and sealing case charts used by Cabrini Green Legal Aid in Illinois.

There are currently two scripts that fill case charts using CSV files produced by the Champaign County Clerk. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cgla_case_chart_assister'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cgla_case_chart_assister

Some scripts also require [PDFTK](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) to be installed on your machine.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Some scripts also require [PDFTK](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) to be installed on your machine.

Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Usage [to update!]

### `convert_to_csv`
We have one general use script for converting Excel files to CSV, `convert_to_csv`.

```
gem install cgla_case_chart_assister
./bin/convert_to_csv <input_dir> <output_dir>
```

**Note:** The provided input directory should have a nested directory containing the file (e.g. file should live at `./input/my-nest-directory/file.xlsx` if `./input` is provided as the input directory). The file will be written into the output directory provided.

### Champaign County utilities

For use in Champaign County, we currently have two scripts (`fill_csv.rb` and `fill_pdf.rb`) though only one is in active use (`fill_csv.rb`).

**The `fill_pdf.rb` script is currently deprecated.** 

```
$ ./bin/[script_name] [path_to_directory_holding_csv_files]
```
`fill_csv` creates a new CSV file in `output/csv` with the eligibility, conviction, waiting period, and notes columns populated.

`fill_pdf` fills two versions of a PDF case chart, one version with only basic charge information in `output/pdf/basic_info` and the other with eligibility determinations on `output/pdf/with_eligibility`.

The script uses the name of the input file to construct the output file name. If the input file name is JONES.csv, the output file name will be JONES_case_chart.csv.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CglaCaseChartAssister project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/cgla_case_chart_assister/blob/master/CODE_OF_CONDUCT.md).
