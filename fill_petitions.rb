#!/usr/bin/env ruby

# CSV Schema
# { individual, date_of_birth, police_agency, case_number, dcn,
#   date_filed, charge, disposition_date, disposition, sentence, balance, conviction, eligibility, wp, notes }

require 'csv'
require 'logger'
require 'pdf-forms'
require_relative 'models/history'
require_relative 'models/event'
require_relative 'parsers/champaign_county_parser'

$pdftk = PdfForms.new

def build_output_file_name(input_file_path, index)
  input_file_name = input_file_path.split('/').last.split('.').first
  "#{input_file_name}_case_chart_#{index}.pdf"
end

def create_pdf(output_file_path, data)
  $pdftk.fill_form "fillable_petition_non_cook.pdf", output_file_path, data
  @logger.info "Created #{output_file_path}"
end

def populate_person_info(history, data)
  data.merge({County: "Champaign",
              Petitioner_Name: history.person_name,
              DOB: history.dob,
             })
  data
end

def populate_case_numbers(history, data)
  eligible_case_ids = expungable_cases(history).map do |c|
    c.case_number
  end
  eligible_arrest_ids = expungable_arrests(history).map {|a| a.dcn}

  eligible_ids = eligible_case_ids + eligible_arrest_ids

  eligible_ids.each_with_index {|id, index|
    data.merge({"Case_Number_#{index + 1}": id})
  }
  data
end

def populate_expunge_info(history, data)
  items = expungable_items(history)
  if items > 0
    data.merge({Expunge_Yes: "Yes", Expunge_No: "Off"})
    items.each_with_index do |item, index|
      if item.class == Event #Arrest event
        data.merge({
                     "Expunge_Case_Number_#{index + 1}": item.dcn,
                     "Expunge_Arresting_Agency_#{index + 1}": item.arresting_agency_code,
                     "Expunge_Charge_#{index + 1}": item.charge_description,
                     "Expunge_Arrest_Date_#{index + 1}": item.date_filed,
                     "Expunge_Outcome_#{index + 1}": 'RWC',
                   })
      else #Court case
        data.merge({
                     "Expunge_Case_Number_#{index + 1}": item.case_number,
                     "Expunge_Arresting_Agency_#{index + 1}": item.events[0].arresting_agency_code,
                     "Expunge_Charge_#{index + 1}": item.events.map {|e| e.charge_code}.join(', '),
                     "Expunge_Arrest_Date_#{index + 1}": item.events[0].date_filed,
                     "Expunge_Outcome_#{index + 1}": determine_outcome(item),
                   })
      end
    end
  else
    data.merge({Expunge_No: "Yes", Expunge_Yes: "Off"})
  end
end

def event_id(row)
  if row[:case_number] != nil
    row[:case_number]
  else
    row[:dcn]
  end
end


def expungable_cases(history)
  history.court_cases.filter do |c|
    c.all_expungable?
  end
end

def expungable_arrests(history)
  history.arrests.filter do |a|
    a.eligibility == 'E'
  end
end

def expungable_items(history)
  expungable_arrests(history) + expungable_cases(history)
end

def fill_petition(history, output_file_name)
  data = {}
  data = populate_person_info(history, data)
  populate_case_numbers(history, data)
  populate_expunge_info(history, data)
  populate_seal_info(history, data)
  output_file_path = "output/pdf/petitions/#{output_file_name}"
  create_pdf(output_file_path, data)
end

@logger = Logger.new(STDOUT)

path_to_directory = ARGV[0]

Dir.glob("*.csv", base: path_to_directory) do |filename|
  input_file_path = "#{path_to_directory}/#{filename}"

  parser = ChampaignCountyParser.new

  history_rows = CSV.read(input_file_path, {headers: true, header_converters: :symbol})
  history = parser.parse_history(history_rows)
  output_file_name = "#{build_output_file_name(input_file_path, index)}"
  fill_petition(history, output_file_name)
end


