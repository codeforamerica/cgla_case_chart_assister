module CglaCaseChartAssister
  History = Struct.new(
    :person_name,
    :ir_number,
    :dob,
    :events,
    :court_cases,
    keyword_init: true
  ) do

    def type
      :history
    end

    def has_pending_case?
      events.any?{|e| e.pending_case?}
    end
  end
end
