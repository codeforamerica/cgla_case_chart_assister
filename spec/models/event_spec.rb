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
      let(:event) {Event.new(dcn: 'L6748494', case_number: '2007-CM-000747')}

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
    context 'when it is a court event' do
      it 'returns true when the disposition is pre-JANO' do
        event = Event.new(disposition: 'Pre-JANO Disposition', case_number: '12345')
        expect(event.pre_JANO?).to eq(true)
      end

      it 'returns false when the disposition is anything else' do
        event = Event.new(disposition: 'some other string', case_number: '12345')
        expect(event.pre_JANO?).to eq(false)
      end
    end

    context 'when it is not a court event' do
      it 'returns false' do
        event = Event.new(disposition: 'Pre-JANO Disposition', case_number: nil)
        expect(event.pre_JANO?).to eq(false)
      end
    end
  end

  describe 'dismissed?' do
    context 'when it is a court event' do
      it 'returns true when the disposition is some form of dismissal' do
        event1 = Event.new(disposition: 'Dismissed', case_number: '12345')
        event2 = Event.new(disposition: 'Dismiss/State Motion', case_number: '12345')
        event3 = Event.new(disposition: 'Dismiss/Want of Prosecution', case_number: '12345')
        expect(event1.dismissed?).to eq(true)
        expect(event2.dismissed?).to eq(true)
        expect(event3.dismissed?).to eq(true)
      end

      it 'returns false if the disposition is empty' do
        event = Event.new(disposition: nil, case_number: '12345')
        expect(event.dismissed?).to eq(false)
      end

      it 'returns false when the disposition is anything else' do
        event = Event.new(disposition: 'some other string', case_number: '12345')
        expect(event.dismissed?).to eq(false)
      end
    end

    context 'when it is not a court event' do
      it 'returns false' do
        event1 = Event.new(disposition: 'Dismissed', case_number: nil)
        event2 = Event.new(disposition: 'Dismiss/State Motion', case_number: nil)
        event3 = Event.new(disposition: 'Dismiss/Want of Prosecution', case_number: nil)
        expect(event1.dismissed?).to eq(false)
        expect(event2.dismissed?).to eq(false)
        expect(event3.dismissed?).to eq(false)
      end
    end

  end

  describe 'acquitted?' do
    context 'when it is a court event' do
      it 'returns true when the disposition is Not Guilty' do
        event = Event.new(disposition: 'Not Guilty', case_number: '12345')
        expect(event.acquitted?).to eq(true)
      end

      it 'returns false when the disposition is anything else' do
        event = Event.new(disposition: 'some other string', case_number: '12345')
        expect(event.acquitted?).to eq(false)
      end
    end

    context 'when it is not a court event' do
      it 'returns false' do
        event = Event.new(disposition: 'Not Guilty', case_number: nil)
        expect(event.acquitted?).to eq(false)
      end
    end
  end

  describe 'conviction?' do
    context 'when it is a court event' do
      it 'returns true when the disposition is Guilty' do
        event = Event.new(disposition: 'Guilty', case_number: '12345')
        expect(event.conviction?).to eq(true)
      end

      it 'returns false when the disposition is anything else' do
        event = Event.new(disposition: 'some other string', case_number: '12345')
        expect(event.conviction?).to eq(false)
      end
    end

    context 'when it is not a court event' do
      it 'returns false' do
        event = Event.new(disposition: 'Guilty', case_number: nil)
        expect(event.conviction?).to eq(false)
      end
    end
  end

  describe 'eligible_for_sealing?' do
    context 'when it is a court event' do
      context 'when the offense the is "T" (traffic)' do
        it 'returns false' do
          event = Event.new(disposition: 'Guilty', charge_code: '720 5/anything', offense_type: 'T', case_number: '12345')
          expect(event.eligible_for_sealing?).to eq(false)
        end
      end

      it 'returns true when the charge code is eligible' do
        event = Event.new(disposition: 'Guilty', charge_code: '720 5/anything', offense_type: 'M', case_number: '12345')
        expect(event.eligible_for_sealing?).to eq(true)
      end

      it 'returns false when the charge code is NOT eligible' do
        event = Event.new(disposition: 'Guilty', charge_code: '720 5/48-1', offense_type: 'M', case_number: '12345')
        expect(event.eligible_for_sealing?).to eq(false)
      end
    end

    context 'when it is not a court event' do
      it 'returns false' do
        event = Event.new(disposition: 'Guilty', charge_code: '720 5/anything', offense_type: 'M', case_number: nil)
        expect(event.eligible_for_expungement?).to eq(false)
      end
    end
  end

  describe 'eligible_for_expungement?' do
    context 'when it is a court event' do
      context 'when the offense the is "T" (traffic)' do
        it 'returns false when the event was dismissed' do
          event = Event.new(disposition: 'Dismissed', offense_type: 'T', case_number: '12345')
          expect(event.eligible_for_expungement?).to eq(false)
        end

        it 'returns false when the event was acquitted' do
          event = Event.new(disposition: 'Not Guilty', offense_type: 'T', case_number: '12345')
          expect(event.eligible_for_expungement?).to eq(false)
        end
      end

      it 'returns true when the event was dismissed' do
        event = Event.new(disposition: 'Dismissed', offense_type: 'F', case_number: '12345')
        expect(event.eligible_for_expungement?).to eq(true)
      end

      it 'returns true when the event was acquitted' do
        event = Event.new(disposition: 'Not Guilty', offense_type: 'F', case_number: '12345')
        expect(event.eligible_for_expungement?).to eq(true)
      end

      it 'returns false when the disposition is anything else' do
        event = Event.new(disposition: 'some other string', offense_type: 'F', case_number: '12345')
        expect(event.eligible_for_expungement?).to eq(false)
      end
    end

    context 'when it is not a court event' do
      it 'returns false' do
        event = Event.new(disposition: 'Dismissed', offense_type: 'F', case_number: nil)
        expect(event.eligible_for_expungement?).to eq(false)
      end
    end
  end

  describe 'sealable_code_section?' do
    context 'when it is a court event' do
      it 'returns false if the code section is a victims compensation charge' do
        event = Event.new(charge_code: '740 45/2(c)', case_number: '12345')
        expect(event.sealable_code_section?).to eq(false)
      end

      it 'returns false if the code section is a dui charge' do
        event = Event.new(charge_code: '625 5/11-501', case_number: '12345')
        expect(event.sealable_code_section?).to eq(false)
      end

      it 'returns false if the code section is a reckless driving charge charge' do
        event = Event.new(charge_code: '625 5/11-503', case_number: '12345')
        expect(event.sealable_code_section?).to eq(false)
      end

      it 'returns false if the code section is an animal cruelty charge' do
        event = Event.new(charge_code: '510 70/1-anything', case_number: '12345')
        expect(event.sealable_code_section?).to eq(false)
      end

      it 'returns false if the code section is a dog fighting charge' do
        event1 = Event.new(charge_code: '720 5/26-5', case_number: '12345')
        event2 = Event.new(charge_code: '720 5/48-1', case_number: '12345')
        expect(event1.sealable_code_section?).to eq(false)
        expect(event2.sealable_code_section?).to eq(false)      end

      it 'returns false if the code section is a domestic battery charge charge' do
        event1 = Event.new(charge_code: '720 5/12-3.1', case_number: '12345')
        event2 = Event.new(charge_code: '720 5/12-3.2(a)(2)', case_number: '12345')
        expect(event1.sealable_code_section?).to eq(false)
        expect(event2.sealable_code_section?).to eq(false)
      end

      it 'returns false if the code section is a no contact violation charge' do
        event1 = Event.new(charge_code: '740 21/anything', case_number: '12345')
        event2 = Event.new(charge_code: '740 22/anything', case_number: '12345')
        expect(event1.sealable_code_section?).to eq(false)
        expect(event2.sealable_code_section?).to eq(false)
      end

      it 'returns false if the code section is a sex abuse charge charge' do
        event1 = Event.new(charge_code: '720 5/12-15', case_number: '12345')
        event2 = Event.new(charge_code: '720 5/12-3.4', case_number: '12345')
        event3 = Event.new(charge_code: '720 5/12-30', case_number: '12345')
        expect(event1.sealable_code_section?).to eq(false)
        expect(event2.sealable_code_section?).to eq(false)
        expect(event3.sealable_code_section?).to eq(false)
      end

      it 'returns false if the code section is a sex crimes charge charge' do
        event1 = Event.new(charge_code: '720 5/11-15', case_number: '12345')
        event2 = Event.new(charge_code: '720 5/11-1(a)', case_number: '12345')
        event3 = Event.new(charge_code: '720 5/11-anything', case_number: '12345')
        expect(event1.sealable_code_section?).to eq(false)
        expect(event2.sealable_code_section?).to eq(false)
        expect(event3.sealable_code_section?).to eq(false)
      end

      it 'returns true if the code section is an exempted sex crimes charge' do
        event1 = Event.new(charge_code: '720 5/11-14', case_number: '12345')
        event2 = Event.new(charge_code: '720 5/11-30', case_number: '12345')
        expect(event1.sealable_code_section?).to eq(true)
        expect(event2.sealable_code_section?).to eq(true)
      end

      it 'returns true if the code section is any other charge' do
        event = Event.new(charge_code: '720 5/anything', case_number: '12345')
        expect(event.sealable_code_section?).to eq(true)
      end
    end

    context 'when it is not a court event' do
      it 'returns false' do
        event = Event.new(charge_code: '720 5/3-4', offense_type: 'F', case_number: nil)
        expect(event.sealable_code_section?).to eq(false)
      end
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

  describe 'expungement_case_chart_hash' do
    context 'when pending_case is false' do
      let(:pending_case) {false}
      it 'returns a hash of eligibility case chart information for the given disposition type and index' do
        dismissal = Event.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          charge_code: '9876',
          charge_description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          disposition: 'Dismissed',
          disposition_date: '10-Oct-2005',
          sentence: 'No Sentence')

        acquittal = Event.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          charge_code: '9876',
          charge_description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          disposition: 'Not Guilty',
          disposition_date: '10-Oct-2005',
          sentence: 'No Sentence')

        dismissal_hash = dismissal.expungement_case_chart_hash(2, pending_case)
        acquittal_hash = acquittal.expungement_case_chart_hash(2, pending_case)

        expect(dismissal_hash).to eq({
                                       "2_is_eligible": 'E',
                                       "2_is_conviction": 'N',
                                       "2_discharge_date": 'N/A',
                                       "2_other_notes": "Toon County Sheriff\nExpunge if no pending cases in other counties. (Dismissal)",
                                     })

        expect(acquittal_hash).to eq({
                                       "2_is_eligible": 'E',
                                       "2_is_conviction": 'N',
                                       "2_discharge_date": 'N/A',
                                       "2_other_notes": "Toon County Sheriff\nExpunge if no pending cases in other counties. (Acquittal)",
                                     })
      end
    end

    context 'when pending_case is true' do
      let(:pending_case) {true}
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

        hash = event.expungement_case_chart_hash(2, pending_case)
        expect(hash).to eq({
                             "2_is_eligible": 'N',
                             "2_is_conviction": 'N',
                             "2_discharge_date": 'N/A',
                             "2_other_notes": "Toon County Sheriff\nPending case in Champaign Co. Expunge once no cases are pending. (Dismissal)",
                           })
      end
    end
  end
end
