module CglaCaseChartAssister
  class NonCookPDFSerializer
    def self.serialize_event(index, event)
      final_disposition = event.dispositions.first
      {
        "#{index}_case_number": event.case_number,
        "#{index}_class": event.offense_class,
        "#{index}_fmqt": event.offense_type,
        "#{index}_charges": "#{event.code} - #{event.description}",
        "#{index}_disposition_date": final_disposition ? "#{final_disposition.description}\n#{final_disposition.date}" : "\n",
        "#{index}_sentence": final_disposition ? final_disposition.sentence_description : nil,
        "#{index}_other_notes": "#{event.arresting_agency}\n",
      }
    end

    def self.serialize_pre_jano_event(index, event)
      final_disposition = event.dispositions.first
      {
        "#{index}_disposition_date": "\n#{final_disposition ? final_disposition.date : nil}",
        "#{index}_sentence": nil,
        "#{index}_is_eligible": nil,
        "#{index}_is_conviction": nil,
        "#{index}_other_notes": "#{event.arresting_agency}\nPre-JANO disposition. Requires manual records check."
      }
    end

    def self.serialize_expungement_event(index, event, pending_case)
      eligible_message = "#{event.arresting_agency}\nExpunge if no pending cases in other counties. #{event.expungement_type}"
      pending_case_message = "#{event.arresting_agency}\nPending case in Champaign Co. Expunge once no cases are pending. #{event.expungement_type}"

      {
        "#{index}_is_eligible": pending_case ? 'N' : 'E',
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
end