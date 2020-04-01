require_relative '../models/event'
require_relative '../models/court_case'
require_relative '../models/history'

class CookCountyParser
  # Returns one History
  def parse_history(rows)
  end

  # Returns one Event
  def parse_event(charge_hash, index)
    split_offense = charge_hash['Degree'].split(' ')
    offense_type = split_offense[2]
    offense_class = split_offense[1]
    event_hash = {
        index: index,
        central_booking_number: nil,
        case_number: charge_hash['case_number'],
        date_filed: nil,
        arresting_agency_code: nil,
        dcn: charge_hash['DCN'],
        charge_code: charge_hash['Statute'],
        charge_description: charge_hash['Charge'],
        offense_type: offense_type,
        offense_class: offense_class,
        disposition: charge_hash['Disposition_description'],
        disposition_date: charge_hash['Disposition_date'],
        sentence: charge_hash['Sentence'],
        discharge_date: nil
    }
    Event.new(event_hash)
  end

  # Returns array of CourtCase
  def parse_court_cases(events)
  end
end
