require_relative '../../models/event'

RSpec.describe Event do
  describe '#court_event?' do
    it 'returns true when case_number is populated' do
      event = Event.new(dcn: 'L6748494', case_number: '2007-CM-000747')
      expect(event.court_event?).to eq(true)
    end

    it 'returns false when case number is empty (arrest record)' do
      arrest_event = Event.new(dcn: 'L6748494', case_number: nil)
      expect(arrest_event.court_event?).to eq(false)
    end
  end

  describe '#pending_case?' do
    context 'when the event is a court event' do
      let(:event) { Event.new(dcn: 'L6748494', case_number: '2007-CM-000747') }

      it 'returns true when neither disposition nor disposition date are populated' do
        event.disposition = nil
        event.disposition_date = nil
        expect(event.pending_case?).to eq(true)
      end

      it 'returns false when disposition or disposition_date or both are populated' do
        event.disposition = 'Guilty'
        event.disposition_date = '3/10/17'
        expect(event.pending_case?).to eq(false)
      end
    end

    it 'returns false when not a court event' do
      arrest_event = Event.new(dcn: 'L6748494', case_number: nil)
      expect(arrest_event.pending_case?).to eq(false)
    end
  end

  describe 'pre_JANO?' do
    it 'returns true when the disposition is pre-JANO' do
      event = Event.new(disposition: 'Pre-JANO Disposition')
      expect(event.pre_JANO?).to eq(true)
    end

    it 'returns false when the disposition is anything else' do
      event = Event.new(disposition: 'some other string')
      expect(event.pre_JANO?).to eq(false)
    end
  end

  describe 'dismissed?' do
    it 'returns true when the disposition is some form of dismissal' do
      event1 = Event.new(disposition: 'Dismissed')
      event2 = Event.new(disposition: 'Dismiss/State Motion')
      event3 = Event.new(disposition: 'Dismiss/Want of Prosecution')
      expect(event1.dismissed?).to eq(true)
      expect(event2.dismissed?).to eq(true)
      expect(event3.dismissed?).to eq(true)
    end

    it 'returns false when the disposition is anything else' do
      event = Event.new(disposition: 'some other string')
      expect(event.dismissed?).to eq(false)
    end
  end

  describe 'acquitted?' do
    it 'returns true when the disposition is Not Guilty' do
      event = Event.new(disposition: 'Not Guilty')
      expect(event.acquitted?).to eq(true)
    end

    it 'returns false when the disposition is anything else' do
      event = Event.new(disposition: 'some other string')
      expect(event.acquitted?).to eq(false)
    end
  end

  describe 'basic_case_chart_hash' do
    it 'returns a hash of the basic case chart information for the given index' do
      event = Event.new(
        case_number: '2005-CM-0012',
        arresting_agency_code: 'Toon County Sheriff',
        charge_code: '9876',
        charge_description: 'Not a good thing',
        offense_type: 'F',
        offense_class: '4',
        disposition: 'Not Guilty',
        disposition_date: '10-Oct-2005',
        sentence: 'No Sentence')

      hash = event.basic_case_chart_hash(4)
      expect(hash).to eq({
                           "4_case_number": '2005-CM-0012',
                           "4_charges": '9876 - Not a good thing',
                           "4_fmqt": 'F',
                           "4_class": '4',
                           "4_disposition_date": "Not Guilty\n10-Oct-2005",
                           "4_sentence": 'No Sentence',
                           "4_other_notes": "Toon County Sheriff\n"
                         })
    end
  end

  describe 'pre_jano_case_chart_hash' do
    it 'returns a hash of some basic and eligibility case chart information for the given index' do
      event = Event.new(
        case_number: '2005-CM-0012',
        arresting_agency_code: 'Toon County Sheriff',
        charge_code: '',
        charge_description: 'Breaking and entering',
        offense_type: nil,
        offense_class: nil,
        disposition: 'Pre-JANO Disposition',
        disposition_date: '10-Oct-2005',
        sentence: 'Pre-JANO Sentence')

      hash = event.pre_jano_case_chart_hash(4)
      expect(hash).to eq({
                           "4_disposition_date": "\n10-Oct-2005",
                           "4_sentence": nil,
                           "4_is_eligible": nil,
                           "4_is_conviction": nil,
                           "4_other_notes": "Toon County Sheriff\nPre-JANO disposition. Requires manual records check.",
                         })
    end
  end

  describe 'dismissal_case_chart_hash' do
    context 'when pending_case is false' do
      let(:pending_case) { false }
      it 'returns a hash of eligibility case chart information for the given index with eligible true' do
        event = Event.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          charge_code: '9876',
          charge_description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          disposition: 'Dismissed',
          disposition_date: '10-Oct-2005',
          sentence: 'No Sentence')

        hash = event.dismissal_case_chart_hash(2, pending_case)
        expect(hash).to eq({
                             "2_is_eligible": 'Y',
                             "2_is_conviction": 'N',
                             "2_discharge_date": 'N/A',
                             "2_other_notes": "Toon County Sheriff\nExpunge if no pending cases in other counties. (Dismissal)",
                           })
      end
    end

    context 'when pending_case is true' do
      let(:pending_case) { true }
      it 'returns a hash of eligibility case chart information for the given index with eligible false' do
        event = Event.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          charge_code: '9876',
          charge_description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          disposition: 'Dismissed',
          disposition_date: '10-Oct-2005',
          sentence: 'No Sentence')

        hash = event.dismissal_case_chart_hash(2, pending_case)
        expect(hash).to eq({
                             "2_is_eligible": 'N',
                             "2_is_conviction": 'N',
                             "2_discharge_date": 'N/A',
                             "2_other_notes": "Toon County Sheriff\nPending case in Champaign Co. Expunge once no cases are pending. (Dismissal)",
                           })
      end
    end
  end

  describe 'acquittal_case_chart_hash' do
    context 'when pending_case is false' do
      let(:pending_case) { false }
      it 'returns a hash of eligibility case chart information for the given index with eligible true' do
        event = Event.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          charge_code: '9876',
          charge_description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          disposition: 'Not Guilty',
          disposition_date: '10-Oct-2005',
          sentence: 'No Sentence')

        hash = event.acquittal_case_chart_hash(2, pending_case)
        expect(hash).to eq({
                             "2_is_eligible": 'Y',
                             "2_is_conviction": 'N',
                             "2_discharge_date": 'N/A',
                             "2_other_notes": "Toon County Sheriff\nExpunge if no pending cases in other counties. (Acquittal)",
                           })
      end
    end

    context 'when pending_case is true' do
      let(:pending_case) { true }
      it 'returns a hash of eligibility case chart information for the given index with eligible false' do
        event = Event.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          charge_code: '9876',
          charge_description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          disposition: 'Dismissed',
          disposition_date: '10-Oct-2005',
          sentence: 'No Sentence')

        hash = event.acquittal_case_chart_hash(2, pending_case)
        expect(hash).to eq({
                             "2_is_eligible": 'N',
                             "2_is_conviction": 'N',
                             "2_discharge_date": 'N/A',
                             "2_other_notes": "Toon County Sheriff\nPending case in Champaign Co. Expunge once no cases are pending. (Acquittal)",
                           })
      end
    end
  end
end