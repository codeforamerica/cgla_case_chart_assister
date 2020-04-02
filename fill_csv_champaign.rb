#!/usr/bin/env ruby

# CSV Schema
# { individual, date_of_birth, police_agency, case_number, dcn,
#   date_filed, charge, disposition_date, disposition, sentence, balance, conviction, eligibility, wp, notes }

require 'csv'
require 'logger'
require_relative 'models/history'
require_relative 'models/charge'
require_relative 'parsers/champaign_county_parser'
require_relative 'eligibility_flows/illinois_eligibility_flow'

def build_output_file_path(input_file_path)
  input_file_name = input_file_path.split('/').last.split('.').first
  "output/csv/#{input_file_name}_case_chart.csv"
end

@logger = Logger.new(STDOUT)

path_to_directory = ARGV[0]
eligibility_flow = IllinoisEligibilityFlow.new

Dir.glob("*.csv", base: path_to_directory) do |filename|
  input_file_path = "#{path_to_directory}/#{filename}"

  history_rows = CSV.read(input_file_path, {headers: true, header_converters: :symbol})
  if history_rows.length > 0

    parser = ChampaignCountyParser.new

    history = parser.parse_history(history_rows)

    CSV.open(build_output_file_path(input_file_path), 'wb') do |output_csv|
      output_csv << history_rows.headers

      history.events.each do |event|
        unless event.offense_class == 'U'
          input_row = history_rows[event.index]
          output_row = eligibility_flow.populate_eligibility(input_row, event, history)
          output_csv << output_row
        end
      end
    end
  else
    puts "Found empty case chart for #{filename}"
  end
end


