CourtCase = Struct.new(:case_number, :events, keyword_init: true) do
  def type
    :court_case
  end

  def all_expungable?
    events.all? {|e| e.eligible_for_expungement?}
  end

  def all_sealable?
    events.all? {|e| e.eligible_for_sealing?}
  end

  def cannot_determine_sealing?
    events.any? {|e| e.charge_code.nil? || e.charge_code.empty?}
  end
end