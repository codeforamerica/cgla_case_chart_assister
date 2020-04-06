module CglaCaseChartAssister
  class EligibilityUpdater
    def self.apply_expungement_eligibility(row, pending_case, event)
      eligible_message = "Expunge if no pending cases in other counties. #{event.expungement_type}"
      pending_case_message = "Pending case in Champaign Co. Expunge once no cases are pending. #{event.expungement_type}"

      row[:conviction] = 'N'
      row[:eligibility] = pending_case ? 'N' : 'E'
      row[:wp] = pending_case ? 'Y' : 'N'
      row[:notes] = pending_case ? pending_case_message : eligible_message
      row
    end

    def self.apply_undetermined_eligibility(row)
      row[:notes] = "Unable to analyze a charge in this case for sealing eligibility. Code section may be missing or formatted incorrectly."
      row
    end

    def self.apply_sealable_eligibility(row, pending_case, event)
      eligible_message = "Charge eligible for sealing, no pending case in Champaign County. Seal if not in waiting period and no pending cases in other counties."
      pending_case_message = "Charge eligible for sealing, but pending case detected in Champaign County."

      row[:conviction] = event.conviction? ? 'Y' : 'N'
      row[:eligibility] = pending_case ? 'N' : 'S'
      row[:wp] = pending_case ? 'Y' : 'TBD'
      row[:notes] = pending_case ? pending_case_message : eligible_message
      row
    end

    def self.apply_disqualified_eligibility(row, event)
      disqualified_event_message = "This charge is permanently ineligible for sealing."
      disqualified_case_message = "Another charge in this case is permanently ineligible for sealing."

      row[:conviction] = event.conviction? ? 'Y' : 'N'
      row[:eligibility] = 'N'
      row[:wp] = 'N/A'
      row[:notes] = event.eligible_for_sealing? ? disqualified_case_message : disqualified_event_message
      row
    end
  end
end
