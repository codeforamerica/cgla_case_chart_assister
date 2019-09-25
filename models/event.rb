Event = Struct.new(
  :central_booking_number,
  :case_number,
  :arrest_date,
  :arresting_agency_code,
  :status_description,
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
    disposition_date != nil && disposition != nil
  end

  def pre_JANO?
    disposition == 'Pre-JANO Disposition'
  end

  def dismissed?
    disposition.start_with?('Dismiss')
  end

  def acquitted?
    disposition == 'Not Guilty'
  end

  def basic_case_chart_hash(index)
    {
      "#{index}_case_number": case_number,
      "#{index}_disposition_date": "#{disposition}\n#{disposition_date}",
      "#{index}_sentence": sentence,
      "#{index}_charges": "#{charge_code} - #{charge_description}",
      "#{index}_class": offense_class,
      "#{index}_fmqt": offense_type
    }
  end

  def pre_jano_case_chart_hash(index)
    {
      "#{index}_disposition_date": "\n#{disposition_date}",
      "#{index}_sentence": nil,
      "#{index}_is_eligible": nil,
      "#{index}_is_conviction": nil,
      "#{index}_other_notes": "\nPre-JANO disposition. Requires manual records check."
    }
  end

  def dismissal_case_chart_hash(index, pending_case)
    eligible_message = "\nExpunge if no pending cases in other counties. (Dismissal)"
    pending_case_message = "\nPending case in Champaign Co. Expunge once no cases are pending. (Dismissal)"

    {
      "#{index}_is_eligible": pending_case ? 'N' : 'Y',
      "#{index}_is_conviction": 'N',
      "#{index}_discharge_date": 'N/A',
      "#{index}_other_notes": pending_case ? pending_case_message : eligible_message,
    }
  end

  def acquittal_case_chart_hash(index, pending_case)
    eligible_message = "\nExpunge if no pending cases in other counties. (Acquittal)"
    pending_case_message = "\nPending case in Champaign Co. Expunge once no cases are pending. (Acquittal)"

    {
      "#{index}_is_eligible": pending_case ? 'N' : 'Y',
      "#{index}_is_conviction": 'N',
      "#{index}_discharge_date": 'N/A',
      "#{index}_other_notes": pending_case ? pending_case_message : eligible_message,
    }
  end
end

# Case Chart Schema
# { client_name, IR_number, aliases, dob,
#   0_central_booking, 0_arrest_date, 0_is_eligible, 0_case_number, 0_disposition_date,
#   0_sentence, 0_discharge_date, 0_fmqt, 0_class, 0_charges, 0_is_conviction, 0_other_notes,
#   1_central_booking, etc...}