module CglaCaseChartAssister
  class History
    def initialize(
      person_name: nil,
      ir_number: nil,
      dob: nil,
      events: [],
      court_cases: []
    )

      @person_name = person_name
      @ir_number = ir_number
      @dob = dob
      @events = events
      @court_cases = court_cases
    end

    attr_reader :person_name, :ir_number, :dob, :events, :court_cases

    def has_pending_case?
      events.any?(&:pending_case?)
    end
  end
end
