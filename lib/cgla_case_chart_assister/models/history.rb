module CglaCaseChartAssister
  History = Struct.new(:person_name, :ir_number, :dob, :events, :court_cases, keyword_init: true) do
    def has_pending_case?
      events.each do |event|
        if event.pending_case?
          return true
        end
      end
      false
    end

    def case_chart_headers_hash
      {client_name: person_name, IR_number: ir_number, dob: dob}
    end
  end
end