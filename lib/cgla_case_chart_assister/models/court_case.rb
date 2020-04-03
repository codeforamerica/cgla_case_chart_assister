module CglaCaseChartAssister
  CourtCase = Struct.new(:case_number, :charges, keyword_init: true) do
    def type
      :court_case
    end

    def all_expungable?
      charges.all? {|e| e.eligible_for_expungement?}
    end

    def all_sealable?
      charges.all? {|e| e.eligible_for_sealing?}
    end

    def cannot_determine_sealing?
      charges.any? {|e| e.code.nil? || e.code.empty?}
    end
  end
end
