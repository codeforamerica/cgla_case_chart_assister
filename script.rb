#!/usr/bin/env ruby

# CSV Schema
# { individual, date_of_birth, arresting_agency, case_number, status_description,
#   date_filed, charge, disposition_date, disposition, sentence, balance, conviction, eligibility, wp, notes }
#
# Case Chart Schema
# { client_name, IR_number, aliases, dob,
#   0_central_booking, 0_arrest_date, 0_is_eligible, 0_case_number, 0_disposition_date,
#   0_sentence, 0_discharge_date, 0_fmqt, 0_class, 0_charges, 0_is_conviction, 0_other_notes,
#   1_central_booking, etc...}

require 'csv'
require 'logger'
require 'pdf-forms'

$pdftk = PdfForms.new

MISDEMEANOR_CLASSES = ['A', 'B', 'C']
FELONY_CLASSES = ['M', 'X', '1', '2', '3', '4']
TRAFFIC_CLASSES = ['U']
# What are N and R?

def extract_header_data(history)
  {client_name: history[0][:individual], dob: history[0][:date_of_birth]}
end

def parse_charge(charge_string)
  charge_elements = charge_string.split(' - ')
  offense_class = charge_elements.pop.split(': ')[1]
  charge = charge_elements.join(' - ')
  {charge: charge, offense_class: offense_class}
end

def determine_offense_type(offense_class)
  if MISDEMEANOR_CLASSES.include?(offense_class)
    'M'
  elsif FELONY_CLASSES.include?(offense_class)
    'F'
  elsif TRAFFIC_CLASSES.include?(offense_class)
    'T'
  else
    nil
  end
end

def populate_basic_event_data(data, event, index)
  data["#{index}_case_number"] = event[:case_number]
  data["#{index}_disposition_date"] = "#{event[:disposition]}\n#{event[:disposition_date]}"
  data["#{index}_sentence"] = event[:sentence]
  charge_info = parse_charge(event[:charge])
  data["#{index}_charges"] = charge_info[:charge]
  data["#{index}_class"] = charge_info[:offense_class]
  data["#{index}_fmqt"] = determine_offense_type(charge_info[:offense_class])
end

def populate_pre_jano_event_data(data, event, index)
  data["#{index}_disposition_date"] = "\n#{event[:disposition_date]}"
  data["#{index}_sentence"] = nil
  data["#{index}_other_notes"] = "\nPre-JANO disposition. Requires manual records check."
end

def populate_dismissal_event_data(data, pending_case, index)
  data["#{index}_is_conviction"] = 'N'
  data["#{index}_discharge_date"] = 'N/A'
  if pending_case
    data["#{index}_other_notes"] = "\nPending case in Champaign Co. Expunge once no cases are pending. (Dismissal)"
    data["#{index}_is_eligible"] = 'N'
  else
    data["#{index}_other_notes"] = "\nExpunge if no pending cases in other counties. (Dismissal)"
    data["#{index}_is_eligible"] = 'Y'
  end
end

def populate_acquittal_event_data(data, pending_case, index)
  data["#{index}_is_conviction"] = 'N'
  data["#{index}_discharge_date"] = 'N/A'
  if pending_case
    data["#{index}_other_notes"] = "\nPending case in Champaign Co. Expunge once no cases are pending. (Acquittal)"
    data["#{index}_is_eligible"] = 'N'
  else
    data["#{index}_other_notes"] = "\nExpunge if no pending cases in other counties. (Acquittal)"
    data["#{index}_is_eligible"] = 'Y'
  end
end

def populate_court_event_data(court_events, pending_case)
  data = {}
  court_events.each_with_index do |event, index|
    populate_basic_event_data(data, event, index)
    if event[:disposition] == 'Pre-JANO Disposition'
      populate_pre_jano_event_data(data, event, index)
    elsif event[:disposition].start_with?('Dismiss')
      populate_dismissal_event_data(data, pending_case, index)
    elsif event[:disposition].start_with?('Not Guilty')
      populate_acquittal_event_data(data, pending_case, index)
    end
  end
  data
end

def has_pending_case?(history)
  # TBD, Active status does not seem to be the right way to determine this
  # history.each do |event|
  #   if event[:status_description] == 'Active'
  #     @logger.info "#{event[:individual]} has a pending case"
  #     return true
  #   end
  # end

  false
end

def build_output_file_name(input_file_path, index)
  input_file_name = input_file_path.split('/').last.split('.').first
  "#{input_file_name}_case_chart_#{index}.pdf"
end

def create_pdf(output_file_path, data)
  $pdftk.fill_form "CGLA_CASE_CHART_FILLABLE.pdf", output_file_path, data
  @logger.info "Created #{output_file_path}"
end

def fill_case_chart(output_file_path, court_events, pending_case)
  header_data = extract_header_data(court_events)
  court_event_data = populate_court_event_data(court_events, pending_case)

  case_chart_data = header_data.merge(court_event_data)
  create_pdf(output_file_path, case_chart_data)
end

@logger = Logger.new(STDOUT)

path_to_directory = ARGV[0]

Dir.glob("*.csv", base: path_to_directory ) do |filename|
  input_file_path = "#{path_to_directory}/#{filename}"

  history = CSV.read(input_file_path, {headers: true, header_converters: :symbol})

  pending_case = has_pending_case?(history)

  court_event_history = history.filter do |event|
    event[:disposition_date] != nil && event[:disposition] != nil
  end

  sorted_court_history = court_event_history.sort_by { |e| Date.parse(e[:date_filed])}

  court_event_chunks = sorted_court_history.each_slice(10)

  court_event_chunks.each_with_index do |court_event_chunk, index|
    output_file_path = "output/#{build_output_file_name(input_file_path, index)}"
    fill_case_chart(output_file_path, court_event_chunk, pending_case)
  end
end


