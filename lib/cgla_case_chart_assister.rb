module CglaCaseChartAssister
  class CglaCaseChartAssisterError < StandardError; end
end

require 'cgla_case_chart_assister/version'

# Models
require 'cgla_case_chart_assister/models/arrest'
require 'cgla_case_chart_assister/models/charge'
require 'cgla_case_chart_assister/models/court_case'
require 'cgla_case_chart_assister/models/disposition'
require 'cgla_case_chart_assister/models/history'

# Eligibility Flows
require 'cgla_case_chart_assister/eligibility_flows/illinois_eligibility_flow'

# Parsers
require 'cgla_case_chart_assister/parsers/champaign_county_parser'
require 'cgla_case_chart_assister/parsers/cook_county_parser'

# Serializers
require 'cgla_case_chart_assister/serializers/non_cook_pdf_serializer'

# Updaters
require 'cgla_case_chart_assister/updaters/eligibility_updater'
