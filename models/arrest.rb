require_relative '../constants/disqualified_code_sections'

Arrest = Struct.new(
  :index,
  :central_booking_number,
  :case_number,
  :date_filed,
  :arresting_agency_code,
  :dcn,
  :code,
  :description,
  :offense_type,
  :offense_class,
  :dispositions,
  keyword_init: true) do

  def type
    :arrest
  end

  def pending_case?
    false
  end

  def pre_JANO?
    false
  end

  def dismissed?
    false
  end

  def acquitted?
    false
  end

  def conviction?
    false
  end

  def fill_eligibility_info?
    false
  end

  def sealable_code_section?
    # Arrests are not sealable by code section
    false
  end

  def disqualified_sex_crime?
    false
  end

  def eligible_for_expungement?
    false
  end

  def eligible_for_sealing?
    false
  end

  def arresting_agency
    arresting_agency_code || 'Agency Not Provided'
  end

  def basic_case_chart_hash(index)
    {
      "#{index}_case_number": dcn,
      "#{index}_class": '',
      "#{index}_fmqt": '',
      "#{index}_charges": "#{code} - #{description}",
      "#{index}_disposition_date": "",
      "#{index}_sentence": '',
      "#{index}_other_notes": "#{arresting_agency}\n",
    }
  end

  def pre_jano_case_chart_hash(index)
    {}
  end

  def expungement_case_chart_hash(index, pending_case)
    {}
  end

  def set_expungement_eligibility_on_csv_row(row, pending_case)
    row
  end

  def set_sealable_eligibility_on_csv_row(row, pending_case)
    row
  end

  def set_undetermined_eligibility_on_csv_row(row)
    row[:notes] = "Not currently analyzing arrests for expungement eligibility"
    row
  end

  def set_disqualified_eligibility_on_csv_row(row)
    row
  end
end

# Case Chart Schema
# { client_name, IR_number, aliases, dob,
#   0_central_booking, 0_arrest_date, 0_is_eligible, 0_case_number, 0_disposition_date,
#   0_sentence, 0_discharge_date, 0_fmqt, 0_class, 0_charges, 0_is_conviction, 0_other_notes,
#   1_central_booking, etc...}