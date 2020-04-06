module CglaCaseChartAssister
  class Disposition
    def initialize(
      case_number: nil,
      charge_index: nil,
      description: nil,
      date: nil,
      sentence_description: nil,
      sentence_duration: nil
    )
      @case_number = case_number
      @charge_index = charge_index
      @description = description
      @date = date
      @sentence_description = sentence_description
      @sentence_duration = sentence_duration
    end

    attr_reader :case_number, :charge_index, :description, :date, :sentence_description, :sentence_duration
  end
end
