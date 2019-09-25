require_relative '../models/event'
require_relative '../models/history'

# CSV Schema
# { individual, date_of_birth, arresting_agency, case_number, status_description,
#   date_filed, charge, disposition_date, disposition, sentence, balance, conviction, eligibility, wp, notes }

MISDEMEANOR_CLASSES = ['A', 'B', 'C']
FELONY_CLASSES = ['M', 'X', '1', '2', '3', '4']
TRAFFIC_CLASSES = ['U']
# What are N and R?

class ChampaignCountyParser
  def parse_history(rows)
    History.new(
      person_name: rows[0][:individual],
      dob: rows[0][:date_of_birth],
      events: rows.map {|row| parse_event(row)}
    )
  end

  def parse_event(row)
    charge_info = parse_charge(row[:charge])
    Event.new(
      case_number: row[:case_number],
      status_description: row[:status_description],
      charge_code: charge_info[:charge_code],
      charge_description: charge_info[:charge_description],
      offense_type: determine_offense_type(charge_info[:offense_class]),
      offense_class: charge_info[:offense_class],
      disposition: row[:disposition],
      disposition_date: row[:disposition_date],
      sentence: row[:sentence]
    )
  end

  private

  def parse_charge(charge_string)
      offense_class = nil
    if charge_string.include?('Class:')
      charge_elements, offense_class = parse_charge_with_class(charge_string)
    else
      charge_elements = charge_string.split('- ')
    end
     charge_code, charge_description = format_charge(charge_elements)
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