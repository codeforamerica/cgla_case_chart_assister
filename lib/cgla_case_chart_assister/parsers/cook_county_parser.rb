require 'cgla_case_chart_assister/models/charge'
require 'cgla_case_chart_assister/models/court_case'
require 'cgla_case_chart_assister/models/disposition'
require 'cgla_case_chart_assister/models/history'
require 'cgla_case_chart_assister/constants/offense_classes'
require 'date'

module CglaCaseChartAssister
  class CookCountyParser
    class << self
      def parse_history(history_json)
        case_details = history_json['CaseDetails']

        court_cases = parse_court_cases(case_details)
        all_charges = court_cases.map(&:charges).flatten

        History.new(
          person_name: parse_name(case_details[0]['Name']),
          ir_number: history_json['IR_number'],
          dob: Date.parse(case_details[0]['Date_of_Birth']),
          events: all_charges,
          court_cases: court_cases
        )
      end

      def parse_court_cases(case_details_array)
        case_details_array.map do |case_details|
          CourtCase.new(
            case_number: case_details['Case_Number'],
            charges: parse_charges(case_details['ChargeDetails'], case_number: case_details['Case_Number'])
          )
        end
      end

      def parse_charges(charge_details, case_number:)
        grouped_details = charge_details.group_by{|charge| charge['Sequence']}
        grouped_details.map do |sequence_id, charge_details_for_sequence|
          reference_charge = charge_details_for_sequence.first
          offense_info = parse_offense_classification(reference_charge['Degree'])

          Charge.new(
            index: sequence_id,
            case_number: case_number,
            dcn: reference_charge['DCN'],
            code: reference_charge['Statute'],
            description: reference_charge['Charge'],
            offense_type: offense_info[:type],
            offense_class: offense_info[:class],
            dispositions: parse_dispositions(charge_details_for_sequence, case_number)
          )
        end
      end

      private

      def parse_name(name_string)
        name_string.split('  ').join(', ')
      end

      def parse_offense_classification(charge_degree)
        offense_info = {}
        charge_degree_parts = charge_degree.split(' ')
        offense_info[:type] = charge_degree_parts.last
        offense_info[:class] = charge_degree_parts[1]
        offense_info
      end

      def parse_dispositions(charge_events, case_number)
        dispositions = []
        charge_events.each do |charge_event|
          dispositions << Disposition.new(
            case_number: case_number,
            charge_index: charge_event['Sequence'],
            description: charge_event['Disposition_description'],
            date: Date.parse(format_disposition_date(charge_event['Disposition_date'])),
            sentence_description: charge_event['Sentence'],
            sentence_duration: charge_event['Sentence_duration']
          )
        end
        dispositions
      end

      def format_disposition_date(disposition_date)
        date_array = disposition_date.split(' ')[0].split('/')
        year = date_array.pop
        date_array.reverse!
        date_array << year
        date_array.join('-')
      end
    end
  end
end

