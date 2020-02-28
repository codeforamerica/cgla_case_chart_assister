require_relative '../constants/disqualified_code_sections'

Event = Struct.new(
  :index,
  :central_booking_number,
  :case_number,
  :date_filed,
  :arresting_agency_code,
  :dcn,
  :charge_code,
  :charge_description,
  :offense_type,
  :offense_class,
  :disposition,
  :disposition_date,
  :sentence,
  :discharge_date,
  keyword_init: true) do

  def court_event?
    case_number != nil
  end

  def pending_case?
    court_event? && disposition == nil && disposition_date == nil
  end

  def pre_JANO?
    court_event? && disposition == 'Pre-JANO Disposition'
  end

  def dismissed?
    court_event? && disposition != nil && disposition.start_with?('Dismiss')
  end

  def acquitted?
    court_event? && disposition == 'Not Guilty'
  end

  def conviction?
    court_event? && disposition == 'Guilty'
  end

  def fill_eligibility_info?
    dismissed? || acquitted? || conviction?
  end

  def sealable_code_section?
    court_event? && !(VICTIMS_COMPENSATION_CODE_SECTION_MATCHER.match(charge_code) ||
      DUI_SECTION_MATCHER.match(charge_code) ||
      RECKLESS_DRIVING_CODE_SECTION_MATCHER.match(charge_code) ||
      ANIMAL_CRUELTY_CODE_SECTION_MATCHER.match(charge_code) ||
      DOG_FIGHTING_CODE_SECTION_MATCHER.match(charge_code) ||
      DOMESTIC_BATTERY_CODE_SECTIONS_MATCHER.match(charge_code) ||
      NO_CONTACT_CODE_SECTIONS_MATCHER.match(charge_code) ||
      SEX_ABUSE_CODE_SECTIONS_MATCHER.match(charge_code) ||
      disqualified_sex_crime?)
  end

  def disqualified_sex_crime?
    match_result = SEX_CRIME_CODE_SECTIONS_MATCHER.match(charge_code)
    !(match_result.nil? ||
      ALLOWED_SEX_CRIME_SUBSECTIONS.include?(match_result[:subsection]))
  end

  def eligible_for_expungement?
    (dismissed? || acquitted?) && offense_type != 'T'
  end

  def eligible_for_sealing?
    sealable_code_section? && offense_type != 'T'
  end

  def arresting_agency
    arresting_agency_code || 'Agency Not Provided'
  end
  
  def expungement_type
    if dismissed?
      '(Dismissal)'
    elsif acquitted?
      '(Acquittal)'
    end
  end
end

# Case Chart Schema
# { client_name, IR_number, aliases, dob,
#   0_central_booking, 0_arrest_date, 0_is_eligible, 0_case_number, 0_disposition_date,
#   0_sentence, 0_discharge_date, 0_fmqt, 0_class, 0_charges, 0_is_conviction, 0_other_notes,
#   1_central_booking, etc...}