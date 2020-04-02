require_relative '../models/charge'
require_relative '../models/court_case'
require_relative '../models/history'
require_relative '../constants/offense_classes'

# CSV Schema
# { individual, date_of_birth, police_agency, case_number, dcn,
#   date_filed, charge, disposition_date, disposition, sentence, balance,
#   conviction, eligibility, wp, notes }

class ChampaignCountyParser
  def parse_history(rows)
    events = rows.each_with_index.map {|row, i| parse_event(row, i)}.compact
    History.new(
      person_name: rows[0][:individual],
      dob: rows[0][:date_of_birth],
      events: events,
      court_cases: parse_court_cases(events)
    )
  end

  def parse_event(row, index)
    if row[:case_number] == nil && row[:dcn] == nil
      return nil
    end
    charge_info = parse_charge(row)
    Charge.new(
      index: index,
      case_number: row[:case_number],
      dcn: row[:dcn],
      arresting_agency_code: row[:police_agency],
      date_filed: row[:date_filed],
      charge_code: charge_info[:charge_code],
      charge_description: charge_info[:charge_description],
      offense_type: determine_offense_type(charge_info[:offense_class]),
      offense_class: charge_info[:offense_class],
      disposition: row[:disposition],
      disposition_date: row[:disposition_date],
      sentence: row[:sentence]
    )
  end

  def parse_court_cases(events)
    events_by_case_number = group_by_case_number(events)
    events_by_case_number.map do |case_number, events_for_case|
      CourtCase.new(case_number: case_number, events: events_for_case)
    end
  end

  private

  def group_by_case_number(events)
    case_number_map = {}
    events.filter {|e| e.court_event?}.each do |e|
      if case_number_map[e.case_number].nil?
        case_number_map[e.case_number] = [e]
      else
        case_number_map[e.case_number] << e
      end
    end
    case_number_map
  end

  def parse_charge(row)
    offense_class = nil
    charge_string = row[:charge]
    begin
      if charge_string.include?('Class:')
        charge_elements, offense_class = parse_charge_with_class(charge_string)
      else
        charge_elements = charge_string.split('- ')
      end
      charge_code, charge_description = format_charge(charge_elements)
    rescue
      puts "Failed to parse charge for #{row}"
    end
    {charge_code: charge_code, charge_description: charge_description, offense_class: offense_class}
  end

  def parse_charge_with_class(charge_string)
    charge_elements = charge_string.split('- ')
    offense_class = charge_elements.pop.split(': ')[1]
    return charge_elements, offense_class
  end

  def format_charge(charge_elements)
    charge_description = charge_elements.pop.strip
    charge_code = nil
    if !charge_elements.empty?
      charge_code = charge_elements[0].strip
    end
    return charge_code, charge_description
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
end