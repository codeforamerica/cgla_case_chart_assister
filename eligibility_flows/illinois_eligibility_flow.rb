require_relative '../updaters/eligibility_updater'

class IllinoisEligibilityFlow
  def populate_eligibility(input_row, event, history)
    unless event.fill_eligibility_info?
      return input_row
    end
    court_case = history.court_cases.find {|c| c.case_number == event.case_number}
    pending_case = history.has_pending_case?

    if court_case.all_expungable?
      EligibilityUpdater.apply_expungement_eligibility(input_row, pending_case, event)
    elsif court_case.cannot_determine_sealing?
      EligibilityUpdater.apply_undetermined_eligibility(input_row)
    elsif court_case.all_sealable?
      EligibilityUpdater.apply_sealable_eligibility(input_row, pending_case, event)
    else
      EligibilityUpdater.apply_disqualified_eligibility(input_row, event)
    end
  end
end
