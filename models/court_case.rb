CourtCase = Struct.new(:case_number, :events, keyword_init: true) do
  def all_expungable?
    events.all? {|e| e.eligible_for_expungement?}
  end
end