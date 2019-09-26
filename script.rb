#!/usr/bin/env ruby

# Case Chart Schema
# { client_name, IR_number, aliases, dob,
#   0_central_booking, 0_arrest_date, 0_is_eligible, 0_case_number, 0_disposition_date,
#   0_sentence, 0_discharge_date, 0_fmqt, 0_class, 0_charges, 0_is_conviction, 0_other_notes,
#   1_central_booking, etc...}

require 'csv'
require 'logger'
require 'pdf-forms'
require_relative 'models/history'
require_relative 'models/event'
require_relative 'parsers/champaign_county_parser'

$pdftk = PdfForms.new

def populate_basic_event_data(data, event, index)
  data.merge(event.basic_case_chart_hash(index))
end

def populate_pre_jano_event_data(data, event, index)
  data.merge(event.pre_jano_case_chart_hash(index))
end

def populate_expungement_event_data(data, event, pending_case, index)
  data.merge(event.expungement_case_chart_hash(index, pending_case))
end

def populate_court_event_data(court_events, pending_case)
  data = {}
  court_events.each_with_index do |event, index|
    data = populate_basic_event_data(data, event, index)
    if event.pre_JANO?
      data = populate_pre_jano_event_data(data, event, index)
    elsif event.eligible_for_expungement?
      data = populate_expungement_event_data(data, event, pending_case, index)
    end
  end
  data
end

def populate_basic_court_event_data(court_events, pending_case)
  data = {}
  court_events.each_with_index do |event, index|
    data = populate_basic_event_data(data, event, index)
    if event.pre_JANO?
      data = populate_pre_jano_event_data(data, event, index)
    end
  end
  data
end

def build_output_file_name(input_file_path, index)
  input_file_name = input_file_path.split('/').last.split('.').first
  "#{input_file_name}_case_chart_#{index}.pdf"
end

def create_pdf(output_file_path, data)
  $pdftk.fill_form "CGLA_CASE_CHART_FILLABLE.pdf", output_file_path, data
  @logger.info "Created #{output_file_path}"
end

def fill_eligibility_case_chart(output_file_name, header_data, court_events, pending_case)
  output_file_path = "output/with_eligibility/#{output_file_name}"
  court_event_data = populate_court_event_data(court_events, pending_case)

  case_chart_data = header_data.merge(court_event_data)
  create_pdf(output_file_path, case_chart_data)
end

def fill_basic_case_chart(output_file_name, header_data, court_events, pending_case)
  output_file_path = "output/basic_info/#{output_file_name}"
  court_event_data = populate_basic_court_event_data(court_events, pending_case)

  case_chart_data = header_data.merge(court_event_data)
  create_pdf(output_file_path, case_chart_data)
end

@logger = Logger.new(STDOUT)

path_to_directory = ARGV[0]

Dir.glob("*.csv", base: path_to_directory) do |filename|
  input_file_path = "#{path_to_directory}/#{filename}"

  history_rows = CSV.read(input_file_path, {headers: true, header_converters: :symbol})

  parser = ChampaignCountyParser.new

  history = parser.parse_history(history_rows)

  pending_case = history.has_pending_case?

  case_chart_header_data = history.case_chart_headers_hash

  court_event_history = history.events.filter {|event| event.court_event?}

  sorted_court_history = court_event_history.sort_by do |e|
    Date.strptime(e.disposition_date, "%m/%d/%y")
  end

  court_event_chunks = sorted_court_history.each_slice(10)

  court_event_chunks.each_with_index do |court_event_chunk, index|
    output_file_name = "#{build_output_file_name(input_file_path, index)}"
    fill_basic_case_chart(output_file_name, case_chart_header_data, court_event_chunk, pending_case)
    fill_eligibility_case_chart(output_file_name, case_chart_header_data, court_event_chunk, pending_case)
  end
end


