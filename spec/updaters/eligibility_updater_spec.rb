require_relative '../../updaters/eligibility_updater'
require_relative '../../models/event'

RSpec.describe EligibilityUpdater do
  describe 'apply_expungement_eligibility' do
    context 'when pending_case is false' do
      let(:pending_case) {false}
      it 'returns the csv hash with eligibility information populated for the given disposition type' do
        dismissal_row = {
          case_number: '2005-CM-0012',
          charge: '9876 - Not a good thing - Class: 4',
          disposition: 'Dismissed'
        }
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

        acquittal_row = {
          case_number: '2005-CM-0012',
          charge: '9876 - Not a good thing - Class: 4',
          disposition: 'Not Guilty'
        }
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

        dismissal_hash = EligibilityUpdater.apply_expungement_eligibility(dismissal_row, pending_case, dismissal)
        acquittal_hash = EligibilityUpdater.apply_expungement_eligibility(acquittal_row, pending_case, acquittal)

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

        acquittal_row = {
          case_number: '2005-CM-0012',
          charge: '9876 - Not a good thing - Class: 4',
          disposition: 'Not Guilty'
        }
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

        dismissal_hash = EligibilityUpdater.apply_expungement_eligibility(dismissal_row, pending_case, dismissal)
        acquittal_hash = EligibilityUpdater.apply_expungement_eligibility(acquittal_row, pending_case, acquittal)

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

  describe 'apply_sealable_eligibility' do
    context 'when pending_case is false' do
      let(:pending_case) {false}
      it 'returns the csv hash with eligibility information populated for the given disposition type' do
        row = {
          case_number: '2005-CM-0012',
          charge: '9876 - Not a good thing - Class: 4',
          disposition: 'Guilty'
        }
        event = Event.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          charge_code: '9876',
          charge_description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          disposition: 'Guilty',
          disposition_date: '10-Oct-2005',
          sentence: 'Jail(10)')

        hash = EligibilityUpdater.apply_sealable_eligibility(row, pending_case, event)

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
        event = Event.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          charge_code: '9876',
          charge_description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          disposition: 'Dismissed',
          disposition_date: '10-Oct-2005',
          sentence: 'Jail(10)')

        hash = EligibilityUpdater.apply_sealable_eligibility(row, pending_case, event)

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

  describe 'apply_disqualified_eligibility' do
    context 'when the given charge code is disqualified' do
      it 'returns the csv hash with disqualified eligibility information for a disqualified charge code' do
        row = {
          case_number: '2005-CM-0012',
          charge: '625 5/11-501 - DUI - Class: 4',
          disposition: 'Guilty'
        }
        event = Event.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          charge_code: '625 5/11-501',
          charge_description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          disposition: 'Guilty',
          disposition_date: '10-Oct-2005',
          sentence: 'Jail(10)')

        hash = EligibilityUpdater.apply_disqualified_eligibility(row, event)

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
        event = Event.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          charge_code: '9876',
          charge_description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          disposition: 'Dismissed',
          disposition_date: '10-Oct-2005',
          sentence: 'Jail(10)')

        hash = EligibilityUpdater.apply_disqualified_eligibility(row, event)

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