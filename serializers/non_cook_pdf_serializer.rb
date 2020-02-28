class NonCookPDFSerializer
  def self.serialize_event(index, event)
    {
      "#{index}_case_number": event.case_number,
      "#{index}_class": event.offense_class,
      "#{index}_fmqt": event.offense_type,
      "#{index}_charges": "#{event.charge_code} - #{event.charge_description}",
      "#{index}_disposition_date": "#{event.disposition}\n#{event.disposition_date}",
      "#{index}_sentence": event.sentence,
      "#{index}_other_notes": "#{event.arresting_agency}\n",
    }
  end

  def self.serialize_pre_jano_event(index, event)
    {
      "#{index}_disposition_date": "\n#{event.disposition_date}",
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