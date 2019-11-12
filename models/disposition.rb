require_relative '../constants/disqualified_code_sections'

Disposition = Struct.new(
  :case_number,
  :charge_segment_id,
  :disposition_code,
  :disposition_date,
  :minimum_term,
  :maximum_term,
  keyword_init: true) do
end
