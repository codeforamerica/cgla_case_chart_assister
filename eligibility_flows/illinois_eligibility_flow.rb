class IllinoisEligibilityFlow
  def populate_eligibility(input_row, event, history)
    unless event.fill_eligibility_info?
      return input_row
    end
    court_case = history.court_cases.find {|c| c.case_number == event.case_number}
    pending_case = history.has_pending_case?
    if court_case.all_expungable?
      event.set_expungement_eligibility_on_csv_row(input_row, pending_case)
    elsif court_case.cannot_determine_sealing?
      event.set_undetermined_eligibility_on_csv_row(input_row)
    elsif court_case.all_sealable?
      event.set_sealable_eligibility_on_csv_row(input_row, pending_case)
    else
      event.set_disqualified_eligibility_on_csv_row(input_row)
    end
  end
end
