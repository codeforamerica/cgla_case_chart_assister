require_relative '../constants/disqualified_code_sections'

Charge = Struct.new(
  :case_number,
  :segment_id,
  :guilty_indicator,
  :charge_code,
  :charge_description,
  :offense_type,
  :offense_class,
  :dispositions,
  keyword_init: true) do

  # def dismissed?
  #   court_event? && disposition != nil && disposition.start_with?('Dismiss')
  # end
  #
  # def acquitted?
  #   court_event? && disposition == 'Not Guilty'
  # end
  #
  # def conviction?
  #   court_event? && disposition == 'Guilty'
  # end

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

  def set_expungement_eligibility_on_csv_row(row, pending_case)
    eligible_message = "Expunge if no pending cases in other counties. #{expungement_type}"
    pending_case_message = "Pending case in Champaign Co. Expunge once no cases are pending. #{expungement_type}"

    row[:conviction] = 'N'
    row[:eligibility] = pending_case ? 'N' : 'E'
    row[:wp] = pending_case ? 'Y' : 'N'
    row[:notes] = pending_case ? pending_case_message : eligible_message
    row
  end

  def set_sealable_eligibility_on_csv_row(row, pending_case)
    eligible_message = "Charge eligible for sealing, no pending case in Champaign County. Seal if not in waiting period and no pending cases in other counties."
    pending_case_message = "Charge eligible for sealing, but pending case detected in Champaign County."

    row[:conviction] = conviction? ? 'Y' : 'N'
    row[:eligibility] = pending_case ? 'N' : 'S'
    row[:wp] = pending_case ? 'Y' : 'TBD'
    row[:notes] = pending_case ? pending_case_message : eligible_message
    row
  end

  def set_undetermined_eligibility_on_csv_row(row)
    row[:notes] = "Unable to analyze a charge in this case for sealing eligibility. Code section may be missing or formatted incorrectly."
    row
  end

  def set_disqualified_eligibility_on_csv_row(row)
    disqualified_event_message = "This charge is permanently ineligible for sealing."
    disqualified_case_message = "Another charge in this case is permanently ineligible for sealing."

    row[:conviction] = conviction? ? 'Y' : 'N'
    row[:eligibility] = 'N'
    row[:wp] = 'N/A'
    row[:notes] = eligible_for_sealing? ? disqualified_case_message : disqualified_event_message
    row
  end

  private

  def expungement_type
    if dismissed?
      '(Dismissal)'
    elsif acquitted?
      '(Acquittal)'
    end
  end
end