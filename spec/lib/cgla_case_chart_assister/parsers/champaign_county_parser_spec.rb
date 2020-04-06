require 'cgla_case_chart_assister'

RSpec.describe CglaCaseChartAssister::ChampaignCountyParser do
  let(:subject) { CglaCaseChartAssister::ChampaignCountyParser.new }
  describe 'parse_event' do
    context 'when a row is unusable (no DCN and no case number)' do
      it 'returns nil' do
        fake_row = {}
        expect(subject.parse_event(fake_row, 3)).to be_nil
      end
    end

    context 'when an event has a case number' do
      it 'builds a Charge using the data from a csv row and an index' do
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
        event = subject.parse_event(fake_row, 3)

        expect(event.type).to eq(:charge)
        expect(event.index).to eq(3)
        expect(event.central_booking_number).to eq(nil)
        expect(event.case_number).to eq('2007-CM-000747')
        expect(event.date_filed).to eq('05-Jul-2007')
        expect(event.arresting_agency_code).to eq('Toon County Sheriff')
        expect(event.dcn).to eq('L6700000')
        expect(event.code).to eq('720 5/21-1(1)(a)')
        expect(event.description).to eq('Knowingly Damage Prop<$300')
        expect(event.offense_type).to eq('M')
        expect(event.offense_class).to eq('A')
        expect(event.dispositions.count).to eq(1)
        expect(event.dispositions.first.description).to eq('Guilty')
        expect(event.dispositions.first.date).to eq('18-Sep-2007')
        expect(event.dispositions.first.sentence_description).to eq('Fines and/or Cost/Penalties and Fees; Probation (24 months); Anti-Crime Assessment Fee;;')
        expect(event.dispositions.first.sentence_duration).to eq(nil)
      end
    end

    context 'when an event has no case number' do
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
        event = subject.parse_event(fake_row, 1)

        expect(event.code).to eq('')
        expect(event.description).to eq('Criminal Trespass To Real Prop')
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
        event = subject.parse_event(fake_row, 1)

        expect(event.code).to eq('720 5/21-1(1)(a)')
        expect(event.description).to eq('Knowingly Damage Prop<$300')
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
        event = subject.parse_event(fake_row, 1)

        expect(event.code).to eq(nil)
        expect(event.description).to eq('Knowingly Damage Prop<$300')
        expect(event.offense_type).to eq(nil)
        expect(event.offense_class).to eq(nil)
      end
    end
  end

  describe 'parse_court_cases' do
    let(:event1) {CglaCaseChartAssister::Charge.new(
      arresting_agency_code: 'Toon Town Sheriff',
      case_number: '2007-CM-000747',
      code: '720 5/21-1(1)(a)',
      description: 'Knowingly Damage Prop<$300',
      offense_type: 'M',
      offense_class: 'A',
      dispositions: [
        CglaCaseChartAssister::Disposition.new(
          description: 'Guilty',
          date: '18-Sep-2007',
          sentence_description: 'Fines and/or Cost/Penalties and Fees; Probation (24 months); Anti-Crime Assessment Fee;;',
        )
      ],
    )}

    let(:event2) {CglaCaseChartAssister::Charge.new(
      arresting_agency_code: 'Toon Town Sheriff',
      case_number: '2007-CM-000747',
      code: nil,
      description: 'Criminal Trespass To Real Prop',
      offense_type: 'M',
      offense_class: 'B',
      dispositions: [
        CglaCaseChartAssister::Disposition.new(
          description: 'Dismissed',
          date: '18-Sep-2007',
          sentence_description: 'No Sentence',
          )
      ],
    )}

    let(:event3) {CglaCaseChartAssister::Charge.new(
      arresting_agency_code: 'Toon Town Sheriff',
      case_number: '2013-CM-000748',
      code: '720 5/21-1(1)(a)',
      description: 'Knowingly Damage Prop<$50',
      offense_type: 'M',
      offense_class: 'C',
      dispositions: [
        CglaCaseChartAssister::Disposition.new(
          description: 'Not Guilty',
          date: '18-Sep-2013',
          sentence_description: 'No Sentence',
        )
      ],
    )}

    let(:event4) {CglaCaseChartAssister::Arrest.new(
      arresting_agency_code: 'Toon Town Sheriff',
      case_number: nil,
      code: nil,
      description: 'Criminal Mischief',
      offense_type: nil,
      offense_class: nil,
      dispositions: nil,
    )}

    it 'creates a court case for each case number' do
      court_cases = subject.parse_court_cases([event1, event2, event3, event4])

      expect(court_cases.length).to eq(2)
      expect(court_cases[0].case_number).to eq('2007-CM-000747')
      expect(court_cases[1].case_number).to eq('2013-CM-000748')
    end

    it 'assigns all court events with a given case number to that court case' do
      court_cases = subject.parse_court_cases([event1, event2, event3, event4])

      expect(court_cases.length).to eq(2)
      expect(court_cases[0].charges.length).to eq(2)
      expect(court_cases[1].charges.length).to eq(1)
    end
  end

  describe 'parse_history' do
    it 'returns a History that contains an Event of each analyzable row provided and corresponding CourtCases' do
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
      expect(history.events.first.type).to eq(:charge)
      expect(history.court_cases.length).to eq(1)
      expect(history.court_cases.first.type).to eq(:court_case)
      expect(history.court_cases.first.case_number).to eq('2007-CM-000747')
    end

    it 'ignores rows that are missing critical information' do
      row1 = {
        individual: 'CHIPMUNK, ALVIN',
        date_of_birth: '02-May-85',
        arresting_agency: nil,
        case_number: nil,
        dcn: nil,
        date_filed: '05-Jul-2009',
        charge: 'Trespassing',
        disposition_date: nil,
        disposition: nil,
        sentence: nil,
        balance: nil,
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

      history = subject.parse_history([row1, row2])

      expect(history.person_name).to eq('CHIPMUNK, ALVIN')
      expect(history.ir_number).to eq(nil)
      expect(history.dob).to eq('02-May-85')
      expect(history.events.length).to eq(1)
      expect(history.events.first.index).to eq(1)
    end
  end
end