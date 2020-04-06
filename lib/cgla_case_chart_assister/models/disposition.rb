require 'cgla_case_chart_assister/constants/disqualified_code_sections'

module CglaCaseChartAssister
  Disposition = Struct.new(
    :case_number,
    :charge_index,
    :description,
    :date,
    :sentence_description,
    :sentence_duration,
    keyword_init: true) do

    def type
      :disposition
    end
  end
end
