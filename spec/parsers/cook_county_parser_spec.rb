require 'json'

require_relative '../../parsers/cook_county_parser'
require_relative '../support/fixture_helper'

RSpec.describe CookCountyParser do
  let(:subject) { CookCountyParser.new }
  let(:history_json) { JSON.parse(FixtureHelper::read_fixture('cook_county.json')) }

  describe '#parse_history' do

  end

  describe '#parse_court_case' do
    it 'builds an array of events from one case detail in the JSON' do
      # case_information = history_json['CaseDetail'][0]
      #
      # event = subject.parse_event(case_information)
      # expect(event.central_booking_number).to eq('0123456789')
      # expect(event.case_number).to eq('00CR1234567')
      # expect(event.date_filed).to eq()
      # expect(event.arresting_agency_code).to eq()
      # expect(event.dcn).to eq('0123456789')
      # expect(event.charge_code).to eq()
      # expect(event.charge_description).to eq('')
      # expect(event.offense_type).to eq('F')
      # expect(event.offense_class).to eq('4')
      # expect(event.disposition).to eq()
      # expect(event.disposition_date).to eq()
      # expect(event.sentence).to eq()
      # expect(event.discharge_date).to eq()
    end
  end

  describe '#parse_event' do
    it 'builds an array of events from one case detail in the JSON' do
      charge_details = {
          DCN: '0123456789',
          Statute: '720-570/402(C)',
          Charge: 'POSS AMT CON SUB EXCEPT(A)/(D)',
          Sentence: 'Probation',
          Sequence: '6',
          Degree: 'Class 4 Felony',
          Disposition_description: 'Finding of Guilty',
          Disposition_date: '10/18/2000 12:00:00 AM',
          Sentence_duration: '0'
      }.merge(case_number: '123coolcase')

      charge_json = JSON.parse(charge_details.to_json)

      event = subject.parse_event(charge_json, 1)
      expect(event.index).to eq(1)
      expect(event.central_booking_number).to be_nil
      expect(event.case_number).to eq('123coolcase')
      expect(event.date_filed).to be_nil
      expect(event.arresting_agency_code).to be_nil
      expect(event.dcn).to eq('0123456789')
      expect(event.charge_code).to eq('720-570/402(C)')
      expect(event.charge_description).to eq('POSS AMT CON SUB EXCEPT(A)/(D)')
      expect(event.offense_type).to eq('F')
      expect(event.offense_class).to eq('4')
      expect(event.disposition).to eq('Finding of Guilty')
      expect(event.disposition_date).to eq('10/18/2000 12:00:00 AM')
      expect(event.sentence).to eq('Probation')
      expect(event.discharge_date).to be_nil
    end

    context 'when degree is violation' do
      it 'returns ' do

      end
    end
  end
end
