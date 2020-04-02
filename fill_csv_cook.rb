#!/usr/bin/env ruby

require 'csv'
require 'logger'
require_relative 'models/history'
require_relative 'models/charge'
require_relative 'parsers/cook_county_parser'
require_relative 'eligibility_flows/illinois_eligibility_flow'

def build_output_file_path(name)
  "output/csv/#{name}_case_chart.csv"
end

@logger = Logger.new(STDOUT)

cases_file_path = ARGV[0]
charges_file_path = ARGV[1]
dispositions_file_path = ARGV[2]
eligibility_flow = IllinoisEligibilityFlow.new
case_chart_headers = [:individual, :date_of_birth, :police_agency, :case_number, :charge, :disposition_date, :disposition, :sentence, :conviction, :eligibility, :waiting_period, :notes]

case_rows = CSV.read(cases_file_path, {headers: true, header_converters: :symbol})
charge_rows = CSV.read(charges_file_path, {headers: true, header_converters: :symbol})
disposition_rows = CSV.read(dispositions_file_path, {headers: true, header_converters: :symbol})

parser = CookCountyParser.new

cases = parser.parse_cases(case_rows, charge_rows, disposition_rows)
histories = parser.parse_histories(cases)

histories.each do |history|

  CSV.open(build_output_file_path(input_file_path), 'wb') do |output_csv|
    output_csv << case_chart_headers

    history.court_cases.each do |court_case|
      output_rows = eligibility_flow.determine_eligibility_for_case(court_case, history)
      output_rows.each {|row| output_csv << row}
    end
  end
end


