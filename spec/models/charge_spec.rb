require 'date'

require_relative '../../models/charge'
require_relative '../../models/disposition'

RSpec.describe Charge do
  let(:event) {Charge.new(dcn: 'L6748494', case_number: '2007-CM-000747')}

  describe '#pending_case?' do

    it 'returns true when neither disposition nor disposition date are populated' do
      event.dispositions = [Disposition.new(description: nil, date: nil)]
      expect(event.pending_case?).to eq(true)
    end

    it 'returns false when disposition or disposition_date or both are populated' do
      event.dispositions = [Disposition.new(description: 'disposition', date: Date.today)]
      expect(event.pending_case?).to eq(false)
    end
  end

  describe 'pre_JANO?' do
    it 'returns true when the disposition is pre-JANO' do
      event.dispositions = [Disposition.new(description: 'Pre-JANO Disposition')]
      expect(event.pre_JANO?).to eq(true)
    end

    it 'returns false when the disposition is anything else' do
      event.dispositions = [Disposition.new(description: 'blah')]
      expect(event.pre_JANO?).to eq(false)
    end
  end

  describe 'dismissed?' do
    it 'returns true when any disposition is some form of dismissal' do
      event1 = Charge.new(dispositions: [Disposition.new(description: 'Dismissed')])
      event2 = Charge.new(dispositions: [Disposition.new(description: 'Dismiss/State Motion')])
      event3 = Charge.new(dispositions: [Disposition.new(description: 'Dismiss/Want of Prosecution')])
      expect(event1.dismissed?).to eq(true)
      expect(event2.dismissed?).to eq(true)
      expect(event3.dismissed?).to eq(true)
    end

    it 'returns false if the disposition description is empty' do
      event.dispositions = [Disposition.new(description: nil)]
      expect(event.dismissed?).to eq(false)
    end

    it 'returns false when the disposition description is anything else' do
      event.dispositions = [Disposition.new(description: 'my fake disposition')]
      expect(event.dismissed?).to eq(false)
    end
  end

  describe 'acquitted?' do
    it 'returns true when the disposition is Not Guilty' do
      event.dispositions = [Disposition.new(description: 'Not Guilty')]
      expect(event.acquitted?).to eq(true)
    end

    it 'returns false if the disposition description is empty' do
      event.dispositions = [Disposition.new(description: nil)]
      expect(event.dismissed?).to eq(false)
    end

    it 'returns false when the disposition is anything else' do
      event.dispositions = [Disposition.new(description: 'my fake disposition')]
      expect(event.acquitted?).to eq(false)
    end
  end

  describe 'conviction?' do
    it 'returns true when the disposition is Guilty' do
      event.dispositions = [Disposition.new(description: 'Guilty')]
      expect(event.conviction?).to eq(true)
    end

    it 'returns false if the disposition description is empty' do
      event.dispositions = [Disposition.new(description: nil)]
      expect(event.dismissed?).to eq(false)
    end

    it 'returns false when the disposition is anything else' do
      event.dispositions = [Disposition.new(description: 'my fake disposition')]
      expect(event.conviction?).to eq(false)
    end
  end

  describe 'eligible_for_sealing?' do
    context 'when the offense the is "T" (traffic)' do
      it 'returns false' do
        event = Charge.new(code: '720 5/anything', offense_type: 'T', dispositions: [Disposition.new(description: 'Guilty')])
        expect(event.eligible_for_sealing?).to eq(false)
      end
    end

    it 'returns true when the charge code is eligible' do
      event = Charge.new(code: '720 5/anything', offense_type: 'M', dispositions: [Disposition.new(description: 'Guilty')])
      expect(event.eligible_for_sealing?).to eq(true)
    end

    it 'returns false when the charge code is NOT eligible' do
      event = Charge.new(code: '720 5/48-1', offense_type: 'M', dispositions: [Disposition.new(description: 'Guilty')])
      expect(event.eligible_for_sealing?).to eq(false)
    end
  end

  describe 'eligible_for_expungement?' do
    context 'when the offense the is "T" (traffic)' do
      it 'returns false when the event was dismissed' do
        event = Charge.new(offense_type: 'T', dispositions: [Disposition.new(description: 'Dismissed')])
        expect(event.eligible_for_expungement?).to eq(false)
      end

      it 'returns false when the event was acquitted' do
        event = Charge.new(offense_type: 'T', dispositions: [Disposition.new(description: 'Not Guilty')])
        expect(event.eligible_for_expungement?).to eq(false)
      end
    end

    it 'returns true when the event was dismissed' do
      event = Charge.new(offense_type: 'F', dispositions: [Disposition.new(description: 'Dismissed')])
      expect(event.eligible_for_expungement?).to eq(true)
    end

    it 'returns true when the event was acquitted' do
      event = Charge.new(offense_type: 'F', dispositions: [Disposition.new(description: 'Not Guilty')])
      expect(event.eligible_for_expungement?).to eq(true)
    end

    it 'returns false when the disposition is anything else' do
      event = Charge.new(offense_type: 'F', dispositions: [Disposition.new(description: 'some other thing')])
      expect(event.eligible_for_expungement?).to eq(false)
    end
  end

  describe 'sealable_code_section?' do
    it 'returns false if the code section is a victims compensation charge' do
      event = Charge.new(code: '740 45/2(c)')
      expect(event.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a dui charge' do
      event = Charge.new(code: '625 5/11-501')
      expect(event.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a reckless driving charge charge' do
      event = Charge.new(code: '625 5/11-503')
      expect(event.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is an animal cruelty charge' do
      event = Charge.new(code: '510 70/1-anything')
      expect(event.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a dog fighting charge' do
      event1 = Charge.new(code: '720 5/26-5')
      event2 = Charge.new(code: '720 5/48-1')
      expect(event1.sealable_code_section?).to eq(false)
      expect(event2.sealable_code_section?).to eq(false)      end

    it 'returns false if the code section is a domestic battery charge charge' do
      event1 = Charge.new(code: '720 5/12-3.1')
      event2 = Charge.new(code: '720 5/12-3.2(a)(2)')
      expect(event1.sealable_code_section?).to eq(false)
      expect(event2.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a no contact violation charge' do
      event1 = Charge.new(code: '740 21/anything')
      event2 = Charge.new(code: '740 22/anything')
      expect(event1.sealable_code_section?).to eq(false)
      expect(event2.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a sex abuse charge charge' do
      event1 = Charge.new(code: '720 5/12-15')
      event2 = Charge.new(code: '720 5/12-3.4')
      event3 = Charge.new(code: '720 5/12-30')
      expect(event1.sealable_code_section?).to eq(false)
      expect(event2.sealable_code_section?).to eq(false)
      expect(event3.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a sex crimes charge charge' do
      event1 = Charge.new(code: '720 5/11-15')
      event2 = Charge.new(code: '720 5/11-1(a)')
      event3 = Charge.new(code: '720 5/11-anything')
      expect(event1.sealable_code_section?).to eq(false)
      expect(event2.sealable_code_section?).to eq(false)
      expect(event3.sealable_code_section?).to eq(false)
    end

    it 'returns true if the code section is an exempted sex crimes charge' do
      event1 = Charge.new(code: '720 5/11-14')
      event2 = Charge.new(code: '720 5/11-30')
      expect(event1.sealable_code_section?).to eq(true)
      expect(event2.sealable_code_section?).to eq(true)
    end

    it 'returns true if the code section is any other charge' do
      event = Charge.new(code: '720 5/anything')
      expect(event.sealable_code_section?).to eq(true)
    end
  end

  describe 'basic_case_chart_hash' do
    it 'returns a hash of the basic case chart information for the given index' do
      event = Charge.new(
        case_number: '2005-CM-0012',
        arresting_agency_code: 'Toon County Sheriff',
        code: '9876',
        description: 'Not a good thing',
        offense_type: 'F',
        offense_class: '4',
        dispositions: [
          Disposition.new(description: 'Not Guilty', date: '10-Oct-2005', sentence_description: 'No Sentence')
        ]
      )

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
      event = Charge.new(
        case_number: '2005-CM-0012',
        arresting_agency_code: 'Toon County Sheriff',
        code: '',
        description: 'Breaking and entering',
        offense_type: nil,
        offense_class: nil,
        dispositions: [
          Disposition.new(description: 'Pre-JANO Disposition', date: '10-Oct-2005', sentence_description: 'Pre-JANO Sentence')
        ]
      )

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
        dismissal = Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              Disposition.new(description: 'Dismissed', date: '10-Oct-2005', sentence_description: 'No Sentence')
          ]
        )

        acquittal = Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              Disposition.new(description: 'Not Guilty', date: '10-Oct-2005', sentence_description: 'No Sentence')
          ]
        )

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
        event = Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              Disposition.new(description: 'Dismissed', date: '10-Oct-2005', sentence_description: 'No Sentence')
          ]
        )

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

  describe 'set_expungement_eligibility_on_csv_row' do
    context 'when pending_case is false' do
      let(:pending_case) {false}
      it 'returns the csv hash with eligibility information populated for the given disposition type' do
        dismissal_row = {
          case_number: '2005-CM-0012',
          charge: '9876 - Not a good thing - Class: 4',
          disposition: 'Dismissed'
        }
        dismissal = Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              Disposition.new(description: 'Dismissed', date: '10-Oct-2005', sentence_description: 'No Sentence')
          ]
        )

        acquittal_row = {
          case_number: '2005-CM-0012',
          charge: '9876 - Not a good thing - Class: 4',
          disposition: 'Not Guilty'
        }
        acquittal = Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              Disposition.new(description: 'Not Guilty', date: '10-Oct-2005', sentence_description: 'No Sentence')
          ]
        )

        dismissal_hash = dismissal.set_expungement_eligibility_on_csv_row(dismissal_row, pending_case)
        acquittal_hash = acquittal.set_expungement_eligibility_on_csv_row(acquittal_row, pending_case)

        expect(dismissal_hash).to eq({
                                       case_number: '2005-CM-0012',
                                       charge: '9876 - Not a good thing - Class: 4',
                                       disposition: 'Dismissed',
                                       eligibility: 'E',
                                       conviction: 'N',
                                       wp: 'N',
                                       notes: "Expunge if no pending cases in other counties. (Dismissal)",
                                     })

        expect(acquittal_hash).to eq({
                                       case_number: '2005-CM-0012',
                                       charge: '9876 - Not a good thing - Class: 4',
                                       disposition: 'Not Guilty',
                                       eligibility: 'E',
                                       conviction: 'N',
                                       wp: 'N',
                                       notes: "Expunge if no pending cases in other counties. (Acquittal)",
                                     })
      end
    end

    context 'when pending_case is true' do
      let(:pending_case) {true}
      it 'returns the csv hash with eligibility set to false for the given disposition type' do
        dismissal_row = {
          case_number: '2005-CM-0012',
          charge: '9876 - Not a good thing - Class: 4',
          disposition: 'Dismissed'
        }
        dismissal = Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              Disposition.new(description: 'Dismissed', date: '10-Oct-2005', sentence_description: 'No Sentence')
          ]
        )

        acquittal_row = {
          case_number: '2005-CM-0012',
          charge: '9876 - Not a good thing - Class: 4',
          disposition: 'Not Guilty'
        }
        acquittal = Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              Disposition.new(description: 'Not Guilty', date: '10-Oct-2005', sentence_description: 'No Sentence')
          ]
        )

        dismissal_hash = dismissal.set_expungement_eligibility_on_csv_row(dismissal_row, pending_case)
        acquittal_hash = acquittal.set_expungement_eligibility_on_csv_row(acquittal_row, pending_case)

        expect(dismissal_hash).to eq({
                                       case_number: '2005-CM-0012',
                                       charge: '9876 - Not a good thing - Class: 4',
                                       disposition: 'Dismissed',
                                       eligibility: 'N',
                                       conviction: 'N',
                                       wp: 'Y',
                                       notes: "Pending case in Champaign Co. Expunge once no cases are pending. (Dismissal)",
                                     })

        expect(acquittal_hash).to eq({
                                       case_number: '2005-CM-0012',
                                       charge: '9876 - Not a good thing - Class: 4',
                                       disposition: 'Not Guilty',
                                       eligibility: 'N',
                                       conviction: 'N',
                                       wp: 'Y',
                                       notes: "Pending case in Champaign Co. Expunge once no cases are pending. (Acquittal)",
                                     })
      end
    end
  end

  describe 'set_sealable_eligibility_on_csv_row' do
    context 'when pending_case is false' do
      let(:pending_case) {false}
      it 'returns the csv hash with eligibility information populated for the given disposition type' do
        row = {
          case_number: '2005-CM-0012',
          charge: '9876 - Not a good thing - Class: 4',
          disposition: 'Guilty'
        }
        event = Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              Disposition.new(description: 'Guilty', date: '10-Oct-2005', sentence_description: 'Jail(10)')
          ]
        )

        hash = event.set_sealable_eligibility_on_csv_row(row, pending_case)

        expect(hash).to eq({
                                       case_number: '2005-CM-0012',
                                       charge: '9876 - Not a good thing - Class: 4',
                                       disposition: 'Guilty',
                                       eligibility: 'S',
                                       conviction: 'Y',
                                       wp: 'TBD',
                                       notes: "Charge eligible for sealing, no pending case in Champaign County. Seal if not in waiting period and no pending cases in other counties.",
                                     })
      end
    end

    context 'when pending_case is true' do
      let(:pending_case) {true}
      it 'returns the csv hash with eligibility set to false for the given disposition type' do
        row = {
          case_number: '2005-CM-0012',
          charge: '9876 - Not a good thing - Class: 4',
          disposition: 'Dismissed'
        }
        event = Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              Disposition.new(description: 'Dismissed', date: '10-Oct-2005', sentence_description: 'Jail(10)')
          ]
        )

        hash = event.set_sealable_eligibility_on_csv_row(row, pending_case)

        expect(hash).to eq({
                             case_number: '2005-CM-0012',
                             charge: '9876 - Not a good thing - Class: 4',
                             disposition: 'Dismissed',
                             eligibility: 'N',
                             conviction: 'N',
                             wp: 'Y',
                             notes: "Charge eligible for sealing, but pending case detected in Champaign County.",
                           })
      end
    end
  end

  describe 'set_disqualified_eligibility_on_csv_row' do
    context 'when the given charge code is disqualified' do
      it 'returns the csv hash with disqualified eligibility information for a disqualified charge code' do
        row = {
          case_number: '2005-CM-0012',
          charge: '625 5/11-501 - DUI - Class: 4',
          disposition: 'Guilty'
        }
        event = Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '625 5/11-501',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              Disposition.new(description: 'Guilty', date: '10-Oct-2005', sentence_description: 'Jail(10)')
          ]
        )

        hash = event.set_disqualified_eligibility_on_csv_row(row)

        expect(hash).to eq({
                             case_number: '2005-CM-0012',
                             charge: '625 5/11-501 - DUI - Class: 4',
                             disposition: 'Guilty',
                             eligibility: 'N',
                             conviction: 'Y',
                             wp: 'N/A',
                             notes: "This charge is permanently ineligible for sealing.",
                           })
      end
    end

    context 'when the event is disqualified, but the given charge code is not on the list disqualified charges' do
      let(:pending_case) {true}
      it 'returns the csv hash with disqualified eligibility information for a sealable charge code' do
        row = {
          case_number: '2005-CM-0012',
          charge: '9876 - Not a good thing - Class: 4',
          disposition: 'Dismissed'
        }
        event = Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              Disposition.new(description: 'Dismissed', date: '10-Oct-2005', sentence_description: 'Jail(10)')
          ]
        )

        hash = event.set_disqualified_eligibility_on_csv_row(row)

        expect(hash).to eq({
                             case_number: '2005-CM-0012',
                             charge: '9876 - Not a good thing - Class: 4',
                             disposition: 'Dismissed',
                             eligibility: 'N',
                             conviction: 'N',
                             wp: 'N/A',
                             notes: "Another charge in this case is permanently ineligible for sealing.",
                           })
      end
    end
  end
end
