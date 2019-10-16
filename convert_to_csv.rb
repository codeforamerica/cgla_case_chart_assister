#!/usr/bin/env ruby

# CSV Schema
# { individual, date_of_birth, police_agency, case_number, dcn,
#   date_filed, charge, disposition_date, disposition, sentence, balance, conviction, eligibility, wp, notes }

require 'csv'
require 'csv'
require 'logger'
require 'roo'

@logger = Logger.new(STDOUT)

def build_output_file_path(filename, output_directory)
  output_file_name = filename.split('.xlsx').first
  "#{output_directory}/#{output_file_name}.csv"
end

input_directory = ARGV[0]
output_directory = ARGV[1]


Dir.glob('**', base: input_directory) do |inner_directory|
  inner_directory_path = "#{input_directory}/#{inner_directory}"
  Dir.glob("*.xlsx", base: inner_directory_path) do |filename|
    input_file_path = "#{inner_directory_path}/#{filename}"
    output_file_path =build_output_file_path(filename, output_directory)

    xls = Roo::Excelx.new(input_file_path)
    xls.to_csv(output_file_path)
  end
end



