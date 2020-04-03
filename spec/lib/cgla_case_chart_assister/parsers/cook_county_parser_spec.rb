require_relative '../../../support/fixture_helper'
require 'cgla_case_chart_assister/parsers/cook_county_parser'
require 'json'
require 'date'

RSpec.describe CglaCaseChartAssister::CookCountyParser do
  let(:subject) { CglaCaseChartAssister::CookCountyParser.new }
  let(:cook_json) { JSON.parse(FixtureHelper.read_fixture('./spec/fixtures/cook_county.json')) }
  describe 'parse_history' do
    it 'returns a History that contains an Event of each analyzable row provided and corresponding CourtCases' do
      history = subject.parse_history(cook_json)

      expect(history.person_name).to eq('DOE, JOHN')
      expect(history.ir_number).to eq('5555555')
      expect(history.dob).to eq(Date.parse('1970-01-03'))
      expect(history.events.length).to eq(5)
      expect(history.events.first.type).to eq(:charge)
      expect(history.court_cases.length).to eq(3)
      expect(history.court_cases.first.type).to eq(:court_case)
      expect(history.court_cases.first.case_number).to eq('00CR1234567')
    end
  end

  describe 'parse_event' do
    let(:charge_json) { [{
                             "DCN" => "0123456789",
                             "Statute" => "720-570/402(C)",
                             "Charge" => "POSS AMT CON SUB EXCEPT(A)/(D)",
                             "Sentence" => "Probation",
                             "Sequence" => "6",
                             "Degree" => "Class 4 Felony",
                             "Disposition_description" => "Finding of Guilty",
                             "Disposition_date" => "10/18/2000 12:00:00 AM",
                             "Sentence_duration" => "0"
                         },
                         {
                             "DCN" => "0123456789",
                             "Statute" => "720-570/402(C)",
                             "Charge" => "POSS AMT CON SUB EXCEPT(A)/(D)",
                             "Sentence" => "Probation",
                             "Sequence" => "6",
                             "Degree" => "Class 4 Felony",
                             "Disposition_description" => "Plea of Guilty",
                             "Disposition_date" => "10/18/2000 12:00:00 AM",
                             "Sentence_duration" => "0"
                         },
                         {
                             "DCN" => "0123456789",
                             "Statute" => "720-570/402(C)",
                             "Charge" => "POSS AMT CON SUB EXCEPT(A)/(D)",
                             "Sentence" => "Probation",
                             "Sequence" => "6",
                             "Degree" => "Class 4 Felony",
                             "Disposition_description" => "Probation Terminated- Satisfactory",
                             "Disposition_date" => "10/18/2000 12:00:00 AM",
                             "Sentence_duration" => "0"
                         }] }
    it 'builds a Charge using the data from the history json and a case number' do
      event = subject.parse_event(charge_json, '123')

      expect(event.type).to eq(:charge)
      expect(event.index).to eq('6')
      expect(event.central_booking_number).to eq(nil)
      expect(event.case_number).to eq('123')
      expect(event.date_filed).to eq(nil)
      expect(event.arresting_agency_code).to eq(nil)
      expect(event.dcn).to eq('0123456789')
      expect(event.code).to eq('720-570/402(C)')
      expect(event.description).to eq('POSS AMT CON SUB EXCEPT(A)/(D)')
      expect(event.offense_type).to eq('Felony')
      expect(event.offense_class).to eq('4')
      expect(event.dispositions.count).to eq(3)
      expect(event.dispositions.first.description).to eq('Finding of Guilty')
      expect(event.dispositions.first.date).to eq(Date.parse('2000-10-18'))
      expect(event.dispositions.first.sentence_description).to eq('Probation')
      expect(event.dispositions.first.sentence_duration).to eq('0')
    end

    xcontext 'when charge event data does not match'

    xcontext 'when degree does not have a class'

    xcontext 'when an event has no case number' do
      it 'builds a Arrest using the data from a csv row and an index' do
        fake_row = {
            individual: 'CHIPMUNK, ALVIN',
            date_of_birth: '02-May-85',
            police_agency: 'Toon County Sheriff',
            case_number: nil,
            dcn: 'L6700000',
            date_filed: '05-Jul-2007',
            charge: 'Knowingly Damage Prop<$300',
            disposition_date: nil,
            disposition: nil,
            sentence: nil,
            balance: '$0.00',
            conviction: nil,
            eligibility: nil,
            wp: nil,
            notes: nil
        }
        event = subject.parse_event(fake_row, 3)

        expect(event.type).to eq(:arrest)
        expect(event.index).to eq(3)
        expect(event.central_booking_number).to eq(nil)
        expect(event.case_number).to eq(nil)
        expect(event.date_filed).to eq('05-Jul-2007')
        expect(event.arresting_agency_code).to eq('Toon County Sheriff')
        expect(event.dcn).to eq('L6700000')
        expect(event.code).to eq(nil)
        expect(event.description).to eq('Knowingly Damage Prop<$300')
        expect(event.offense_type).to eq(nil)
        expect(event.offense_class).to eq(nil)
        expect(event.dispositions).to eq(nil)
      end
    end

    xcontext 'when the charge code is missing' do
      it 'correctly parses the other charge elements' do
        fake_row = {
            individual: 'CHIPMUNK, ALVIN',
            date_of_birth: '02-May-85',
            arresting_agency: nil,
            case_number: '2007-CM-000747',
            date_filed: '05-Jul-2007',
            charge: '- Criminal Trespass To Real Prop - Class: B',
            disposition_date: '18-Sep-2007',
            disposition: 'Guilty',
            sentence: 'Fines and/or Cost/Penalties and Fees; Probation (24 months); Anti-Crime Assessment Fee;;',
            balance: '$0.00',
            conviction: nil,
            eligibility: nil,
            wp: nil,
            notes: nil
        }
        event = subject.parse_event(fake_row, 1)

        expect(event.code).to eq('')
        expect(event.description).to eq('Criminal Trespass To Real Prop')
        expect(event.offense_type).to eq('M')
        expect(event.offense_class).to eq('B')
      end
    end

    xcontext 'when the offense class is missing' do
      it 'correctly parses the other charge elements and leaves offense type blank' do
        fake_row = {
            individual: 'CHIPMUNK, ALVIN',
            date_of_birth: '02-May-85',
            arresting_agency: nil,
            case_number: '2007-CM-000747',
            date_filed: '05-Jul-2007',
            charge: '720 5/21-1(1)(a) - Knowingly Damage Prop<$300 - Class:',
            disposition_date: '18-Sep-2007',
            disposition: 'Guilty',
            sentence: 'Fines and/or Cost/Penalties and Fees; Probation (24 months); Anti-Crime Assessment Fee;;',
            balance: '$0.00',
            conviction: nil,
            eligibility: nil,
            wp: nil,
            notes: nil
        }
        event = subject.parse_event(fake_row, 1)

        expect(event.code).to eq('720 5/21-1(1)(a)')
        expect(event.description).to eq('Knowingly Damage Prop<$300')
        expect(event.offense_type).to eq(nil)
        expect(event.offense_class).to eq(nil)
      end
    end

    xcontext 'when there is only a charge description' do
      it 'correctly parses the description and leaves the other fields blank' do
        fake_row = {
            individual: 'CHIPMUNK, ALVIN',
            date_of_birth: '02-May-85',
            arresting_agency: nil,
            case_number: '2007-CM-000747',
            date_filed: '05-Jul-2007',
            charge: 'Knowingly Damage Prop<$300',
            disposition_date: '18-Sep-2007',
            disposition: 'Guilty',
            sentence: 'Fines and/or Cost/Penalties and Fees; Probation (24 months); Anti-Crime Assessment Fee;;',
            balance: '$0.00',
            conviction: nil,
            eligibility: nil,
            wp: nil,
            notes: nil
        }
        event = subject.parse_event(fake_row, 1)

        expect(event.code).to eq(nil)
        expect(event.description).to eq('Knowingly Damage Prop<$300')
        expect(event.offense_type).to eq(nil)
        expect(event.offense_class).to eq(nil)
      end
    end
  end

  describe 'parse_court_cases' do
    let(:case_details) { cook_json['CaseDetails'] }
    it 'creates a court case for each case number' do
      court_cases = subject.parse_court_cases(case_details)

      expect(court_cases.length).to eq(3)
      expect(court_cases[0].case_number).to eq('00CR1234567')
      expect(court_cases[1].case_number).to eq('14CR0123456')
      expect(court_cases[2].case_number).to eq('95CR0127401')
    end

    # it 'assigns all court events with a given case number to that court case' do
    #   expect(court_cases.length).to eq(3)
    #   expect(court_cases[0].events.length).to eq(2)
    #   expect(court_cases[1].events.length).to eq(1)
    # end
  end
end
