#!/usr/bin/env ruby

# CSV Schema
# { individual, date_of_birth, arresting_agency, case_number, status_description,
#   date_filed, charge, disposition_date, disposition, sentence, balance, conviction, eligibility, wp, notes }
#
# Case Chart Schema
# { client_name, IR_number, aliases, dob,
#   0_central_booking, 0_arrest_date, 0_is_eligible, 0_case_number, 0_disposition_date,
#   0_sentence, 0_discharge_date, 0_class, 0_charges, 0_is_conviction, 0_other_notes,
#   1_central_booking, etc...}

require 'csv'
require 'logger'
require 'pdf-forms'

$pdftk = PdfForms.new

def extract_header_data(history)
  {client_name: history[0][:individual], dob: history[0][:date_of_birth]}
end

def build_output_file_name(input_file_path)
  input_file_name = input_file_path.split('/').last.split('.').first
  "#{input_file_name}_case_chart.pdf"
end

def create_pdf(input_file_path, data)
  output_file_path = "output/#{build_output_file_name(input_file_path)}"
  $pdftk.fill_form "CGLA_CASE_CHART_FILLABLE.pdf", output_file_path, data
  @logger.info "Created #{output_file_path}"
end

@logger = Logger.new(STDOUT)

path_to_file = ARGV[0]

history = CSV.read(path_to_file, {headers: true, header_converters: :symbol})

case_chart_header_data = extract_header_data(history)

create_pdf(path_to_file, case_chart_header_data)
