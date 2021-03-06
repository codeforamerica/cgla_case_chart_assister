module CglaCaseChartAssister
  class CourtCase
    def initialize(
      case_number: nil,
      person_name: nil,
      central_booking_number: nil,
      charges: []
    )

      @case_number = case_number
      @person_name = person_name
      @central_booking_number = central_booking_number
      @charges = charges
    end

    attr_reader :case_number, :person_name, :central_booking_number, :charges

    def all_expungable?
      charges.all?(&:eligible_for_expungement?)
    end

    def all_sealable?
      charges.all?(&:eligible_for_sealing?)
    end

    def cannot_determine_sealing?
      charges.any? { |e| e.code.nil? || e.code.empty? }
    end
  end
end
