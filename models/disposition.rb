require_relative '../constants/disqualified_code_sections'

Disposition = Struct.new(
  :case_number,
  :charge_index,
  :description,
  :date,
  :sentence_description,
  :sentence_duration,
  keyword_init: true) do
end
