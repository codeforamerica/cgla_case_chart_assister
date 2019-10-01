#!/usr/bin/env ruby

# CSV Schema
# { individual, date_of_birth, police_agency, case_number, dcn,
#   date_filed, charge, disposition_date, disposition, sentence, balance, conviction, eligibility, wp, notes }

require 'csv'
require 'logger'
require_relative 'models/history'
require_relative 'models/event'
require_relative 'parsers/champaign_county_parser'

def build_output_file_path(input_file_path)
  input_file_name = input_file_path.split('/').last.split('.').first
  "output/csv/#{input_file_name}_case_chart.csv"
end

def populate_eligibility(input_row, event, pending_case, history)
  if event.eligible_for_expungement? && history.court_cases.find{ |c| c.case_number == event.case_number}.all_expungable?
    event.set_expungement_eligibility_on_csv_row(input_row, pending_case)
  else
    input_row
  end
end

@logger = Logger.new(STDOUT)

path_to_directory = ARGV[0]

Dir.glob("*.csv", base: path_to_directory) do |filename|
  input_file_path = "#{path_to_directory}/#{filename}"

  history_rows = CSV.read(input_file_path, { headers: true, header_converters: :symbol })

  parser = ChampaignCountyParser.new

  history = parser.parse_history(history_rows)

  pending_case = history.has_pending_case?

  CSV.open(build_output_file_path(input_file_path), 'wb') do |output_csv|
    output_csv << history_rows.headers

    history.events.each_with_index do |event, index|
      unless event.offense_class == 'U'
        input_row = history_rows[index]
        output_row = populate_eligibility(input_row, event, pending_case, history)
        output_csv << output_row
      end
    end
  end
end


