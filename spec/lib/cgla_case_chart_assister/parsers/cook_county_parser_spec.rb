require_relative '../../../support/fixture_helper'
require 'cgla_case_chart_assister'
require 'json'
require 'date'

RSpec.describe CglaCaseChartAssister::CookCountyParser do
  let(:cook_json) { JSON.parse(FixtureHelper.read_fixture('./spec/fixtures/cook_county.json')) }

  describe 'parse_history' do
    context 'when case details are present' do
      it 'returns a History that contains an Event of each analyzable row provided and corresponding CourtCases' do
        history = CglaCaseChartAssister::CookCountyParser.parse_history(cook_json)

        expect(history.person_name).to eq('DOE, JOHN')
        expect(history.ir_number).to eq('5555555')
        expect(history.dob).to eq(Date.parse('1970-01-03'))
        expect(history.events.length).to eq(5)
        expect(history.events.first).to be_a(CglaCaseChartAssister::Charge)
        expect(history.court_cases.length).to eq(3)
        expect(history.court_cases.first.case_number).to eq('00CR1234567')
      end
    end

    context 'when case details are not present' do
      let(:cook_json) { JSON.parse(FixtureHelper.read_fixture('./spec/fixtures/cook_county_empty.json')) }

      it 'returns a History with empty information' do
        history = CglaCaseChartAssister::CookCountyParser.parse_history(cook_json)

        expect(history.person_name).to eq(nil)
        expect(history.ir_number).to eq('asldfkjasdf')
        expect(history.dob).to eq(nil)
        expect(history.events.length).to eq(0)
        expect(history.court_cases.length).to eq(0)
      end
    end
  end

  describe 'parse_court_cases' do
    let(:case_details) { cook_json['CaseDetails'] }
    it 'creates a court case for each case number' do
      court_cases = CglaCaseChartAssister::CookCountyParser.parse_court_cases(case_details)

      expect(court_cases.length).to eq(3)
      expect(court_cases[0].case_number).to eq('00CR1234567')
      expect(court_cases[0].charges.length).to eq(2)
      expect(court_cases[1].case_number).to eq('14CR0123456')
      expect(court_cases[1].charges.length).to eq(2)
      expect(court_cases[2].case_number).to eq('95CR0127401')
      expect(court_cases[2].charges.length).to eq(1)
    end
  end

  describe 'parse_charges' do
    let(:charge_details) { cook_json['CaseDetails'][0]['ChargeDetails'] }
    it 'creates a charge for every unique sequence in ChargeDetails' do
      charges = CglaCaseChartAssister::CookCountyParser.parse_charges(charge_details, case_number: '00CR1234567')

      expect(charges.length).to eq(2)
      expect(charges.all?{|c| c.is_a?(CglaCaseChartAssister::Charge) }).to eq(true)

      expect(charges[0].index).to eq('1')
      expect(charges[0].case_number).to eq('00CR1234567')
      expect(charges[0].dcn).to eq('0123456789')
      expect(charges[0].code).to eq('VOP')
      expect(charges[0].description).to eq('Violation of Probation - Office Use Only')
      expect(charges[0].offense_type).to eq('Violation')
      expect(charges[0].offense_class).to eq(nil)
      expect(charges[0].dispositions.length).to eq(1)
      expect(charges[0].dispositions.first.description).to eq(nil)
      expect(charges[0].dispositions.first.date).to eq(Date.parse('2000-10-18'))
      expect(charges[0].dispositions.first.sentence_description).to eq('Probation')
      expect(charges[0].dispositions.first.sentence_duration).to eq('0')

      expect(charges[1].index).to eq('6')
      expect(charges[1].case_number).to eq('00CR1234567')
      expect(charges[1].dcn).to eq('0123456789')
      expect(charges[1].code).to eq('720-570/402(C)')
      expect(charges[1].description).to eq('POSS AMT CON SUB EXCEPT(A)/(D)')
      expect(charges[1].offense_type).to eq('Felony')
      expect(charges[1].offense_class).to eq('4')
      expect(charges[1].dispositions.length).to eq(3)
      expect(charges[1].dispositions.first.description).to eq('Finding of Guilty')
      expect(charges[1].dispositions.first.date).to eq(Date.parse('2000-10-18'))
      expect(charges[1].dispositions.first.sentence_description).to eq('Probation')
      expect(charges[1].dispositions.first.sentence_duration).to eq('0')
    end
  end
end
