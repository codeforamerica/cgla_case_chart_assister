Event = Struct.new(
  :central_booking_number,
  :case_number,
  :arrest_date,
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
    court_event? && disposition.start_with?('Dismiss')
  end

  def acquitted?
    court_event? && disposition == 'Not Guilty'
  end

  def eligible_for_expungement?
    (dismissed? || acquitted?) && offense_type != 'T'
  end

  def arresting_agency
    arresting_agency_code || 'Agency Not Provided'
  end

  def basic_case_chart_hash(index)
    {
      "#{index}_case_number": case_number,
      "#{index}_class": offense_class,
      "#{index}_fmqt": offense_type,
      "#{index}_charges": "#{charge_code} - #{charge_description}",
      "#{index}_disposition_date": "#{disposition}\n#{disposition_date}",
      "#{index}_sentence": sentence,
      "#{index}_other_notes": "#{arresting_agency}\n",
    }
  end

  def pre_jano_case_chart_hash(index)
    {
      "#{index}_disposition_date": "\n#{disposition_date}",
      "#{index}_sentence": nil,
      "#{index}_is_eligible": nil,
      "#{index}_is_conviction": nil,
      "#{index}_other_notes": "#{arresting_agency}\nPre-JANO disposition. Requires manual records check."
    }
  end

  def expungement_case_chart_hash(index, pending_case)
    eligible_message = "#{arresting_agency}\nExpunge if no pending cases in other counties. #{expungement_type}"
    pending_case_message = "#{arresting_agency}\nPending case in Champaign Co. Expunge once no cases are pending. #{expungement_type}"

    {
      "#{index}_is_eligible": pending_case ? 'N' : 'E',
      "#{index}_is_conviction": 'N',
      "#{index}_discharge_date": 'N/A',
      "#{index}_other_notes": pending_case ? pending_case_message : eligible_message,
    }
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

  private

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