require_relative '../../parsers/champaign_county_parser'

RSpec.describe ChampaignCountyParser do
  let(:subject) {ChampaignCountyParser.new}
  describe 'parse_event' do
    it 'builds an Event using the data from a csv row' do
      fake_row = {
        individual: 'CHIPMUNK, ALVIN',
        date_of_birth: '02-May-85',
        police_agency: 'Toon County Sheriff',
        case_number: '2007-CM-000747',
        dcn: 'L6700000',
        date_filed: '05-Jul-2007',
        charge: '720 5/21-1(1)(a) - Knowingly Damage Prop<$300 - Class: A',
        disposition_date: '18-Sep-2007',
        disposition: 'Guilty',
        sentence: 'Fines and/or Cost/Penalties and Fees; Probation (24 months); Anti-Crime Assessment Fee;;',
        balance: '$0.00',
        conviction: nil,
        eligibility: nil,
        wp: nil,
        notes: nil
      }
      event = subject.parse_event(fake_row)

      expect(event.central_booking_number).to eq(nil)
      expect(event.case_number).to eq('2007-CM-000747')
      expect(event.date_filed).to eq('05-Jul-2007')
      expect(event.arresting_agency_code).to eq('Toon County Sheriff')
      expect(event.dcn).to eq('L6700000')
      expect(event.charge_code).to eq('720 5/21-1(1)(a)')
      expect(event.charge_description).to eq('Knowingly Damage Prop<$300')
      expect(event.offense_type).to eq('M')
      expect(event.offense_class).to eq('A')
      expect(event.disposition).to eq('Guilty')
      expect(event.disposition_date).to eq('18-Sep-2007')
      expect(event.sentence).to eq('Fines and/or Cost/Penalties and Fees; Probation (24 months); Anti-Crime Assessment Fee;;')
      expect(event.discharge_date).to eq(nil)
    end

    context 'when the charge code is missing' do
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
        event = subject.parse_event(fake_row)

        expect(event.charge_code).to eq('')
        expect(event.charge_description).to eq('Criminal Trespass To Real Prop')
        expect(event.offense_type).to eq('M')
        expect(event.offense_class).to eq('B')
      end
    end

    context 'when the offense class is missing' do
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
        event = subject.parse_event(fake_row)

        expect(event.charge_code).to eq('720 5/21-1(1)(a)')
        expect(event.charge_description).to eq('Knowingly Damage Prop<$300')
        expect(event.offense_type).to eq(nil)
        expect(event.offense_class).to eq(nil)
      end
    end

    context 'when there is only a charge description' do
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
        event = subject.parse_event(fake_row)

        expect(event.charge_code).to eq(nil)
        expect(event.charge_description).to eq('Knowingly Damage Prop<$300')
        expect(event.offense_type).to eq(nil)
        expect(event.offense_class).to eq(nil)
      end
    end
  end

  describe 'parse_court_cases' do
    let(:row1) {Event.new(
      arresting_agency_code: 'Toon Town Sheriff',
      case_number: '2007-CM-000747',
      charge_code: '720 5/21-1(1)(a)',
      charge_description: 'Knowingly Damage Prop<$300',
      offense_type: 'M',
      offense_class: 'A',
      disposition_date: '18-Sep-2007',
      disposition: 'Guilty',
      sentence: 'Fines and/or Cost/Penalties and Fees; Probation (24 months); Anti-Crime Assessment Fee;;',
      )}

    let(:row2) {Event.new(
      arresting_agency_code: 'Toon Town Sheriff',
      case_number: '2007-CM-000747',
      charge_code: nil,
      charge_description: 'Criminal Trespass To Real Prop',
      offense_type: 'M',
      offense_class: 'B',
      disposition_date: '18-Sep-2007',
      disposition: 'Dismissed',
      sentence: 'No Sentence',
      )}

    let(:row3) {Event.new(
      arresting_agency_code: 'Toon Town Sheriff',
      case_number: '2013-CM-000748',
      charge_code: '720 5/21-1(1)(a)',
      charge_description: 'Knowingly Damage Prop<$50',
      offense_type: 'M',
      offense_class: 'C',
      disposition_date: '18-Sep-2013',
      disposition: 'Not Guilty',
      sentence: 'No Sentence',
      )}

    let(:row4) {Event.new(
      arresting_agency_code: 'Toon Town Sheriff',
      case_number: nil,
      charge_code: nil,
      charge_description: 'Criminal Mischief',
      offense_type: nil,
      offense_class: nil,
      disposition_date: nil,
      disposition: nil,
      sentence: nil,
      )}
    it 'creates a court case for each case number' do
      court_cases = subject.parse_court_cases([row1, row2, row3, row4])

      expect(court_cases.length).to eq(2)
      expect(court_cases[0].case_number).to eq('2007-CM-000747')
      expect(court_cases[1].case_number).to eq('2013-CM-000748')
    end

    it 'assigns all court events with a given case number to that court case' do
      court_cases = subject.parse_court_cases([row1, row2, row3, row4])

      expect(court_cases.length).to eq(2)
      expect(court_cases[0].events.length).to eq(2)
      expect(court_cases[1].events.length).to eq(1)
    end
  end

  describe 'parse_history' do
    it 'returns a History that contains an Event of each row provided and corresponding CourtCases' do
      row1 = {
        individual: 'CHIPMUNK, ALVIN',
        date_of_birth: '02-May-85',
        arresting_agency: nil,
        case_number: '2007-CM-000747',
        status_description: 'Closed',
        date_filed: '05-Jul-2007',
        charge: '720 5/21-1(1)(a) - Knowingly Damage Prop<$300 - Class: A',
        disposition_date: '18-Sep-2007',
        disposition: 'Guilty',
        sentence: 'Fines and/or Cost/Penalties and Fees; Probation (24 months); Anti-Crime Assessment Fee;;',
        balance: '$0.00',
        conviction: nil,
        eligibility: nil,
        wp: nil,
        notes: nil
      }

      row2 = {
        individual: 'CHIPMUNK, ALVIN',
        date_of_birth: '02-May-85',
        arresting_agency: nil,
        case_number: '2007-CM-000747',
        date_filed: '05-Jul-2009',
        charge: '- Criminal Trespass To Real Prop - Class: B',
        disposition_date: '18-Sep-2007',
        disposition: 'Dismissed',
        sentence: 'No Sentence',
        balance: '$0.00',
        conviction: nil,
        eligibility: nil,
        wp: nil,
        notes: nil
      }
      history = subject.parse_history([row1, row2])

      expect(history.person_name).to eq('CHIPMUNK, ALVIN')
      expect(history.ir_number).to eq(nil)
      expect(history.dob).to eq('02-May-85')
      expect(history.events.length).to eq(2)
      expect(history.events.first.class).to eq(Event)
      expect(history.court_cases.length).to eq(1)
      expect(history.court_cases.first.class).to eq(CourtCase)
      expect(history.court_cases.first.case_number).to eq('2007-CM-000747')
    end
  end
end