require_relative '../../models/arrest'

RSpec.describe Arrest do
  let(:arrest) {Arrest.new}
  describe '#pending_case?' do
    it 'returns false' do
      expect(arrest.pending_case?).to eq(false)
    end
  end

  describe 'pre_JANO?' do
    it 'returns false' do
      expect(arrest.pre_JANO?).to eq(false)
    end
  end

  describe 'dismissed?' do
    it 'returns false' do
      expect(arrest.dismissed?).to eq(false)
    end
  end

  describe 'acquitted?' do
    it 'returns false' do
      expect(arrest.acquitted?).to eq(false)
    end
  end

  describe 'conviction?' do
    it 'returns false' do
      expect(arrest.conviction?).to eq(false)
    end
  end

  describe 'eligible_for_sealing?' do
    it 'returns false' do
      expect(arrest.eligible_for_sealing?).to eq(false)
    end
  end

  describe 'eligible_for_expungement?' do
    xcontext 'when was released without charge' do
      #   We're not sure how to determine this from the data yet, but this is the eligibility logic
    end

    it 'returns false' do
      expect(arrest.eligible_for_expungement?).to eq(false)
    end
  end

  describe 'sealable_code_section?' do
    it 'returns false' do
      expect(arrest.sealable_code_section?).to eq(false)
    end
  end

  describe 'basic_case_chart_hash' do
    it 'returns a hash of the basic case chart information for the given index using DCN for case number' do
      event = Arrest.new(
        case_number: nil,
        dcn: '1234',
        arresting_agency_code: 'Toon County Sheriff',
        code: '9876',
        description: 'Not a good thing',
        offense_type: nil,
        offense_class: nil,
        dispositions: nil
      )

      hash = event.basic_case_chart_hash(4)
      expect(hash).to eq({
                           "4_case_number": '1234',
                           "4_charges": '9876 - Not a good thing',
                           "4_fmqt": '',
                           "4_class": '',
                           "4_disposition_date": '',
                           "4_sentence": '',
                           "4_other_notes": "Toon County Sheriff\n"
                         })
    end
  end

  describe 'pre_jano_case_chart_hash' do
    it 'returns an empty hash' do
      event = Arrest.new(
        dcn: '2005-CM-0012',
        arresting_agency_code: 'Toon County Sheriff',
        code: '',
        description: 'Breaking and entering',
        offense_type: nil,
        offense_class: nil,
        dispositions: nil,
      )

      hash = event.pre_jano_case_chart_hash(4)
      expect(hash).to eq({})
    end
  end

  describe 'expungement_case_chart_hash' do
    it 'returns a hash of eligibility case chart information for the given disposition type and index' do
      event = Arrest.new(
        dcn: '2005-CM-0012',
        arresting_agency_code: 'Toon County Sheriff',
        code: '9876',
        description: 'Not a good thing',
        dispositions: nil,
      )

      event_hash = event.expungement_case_chart_hash(2, false)

      expect(event_hash).to eq({})
    end
  end

  describe 'set_expungement_eligibility_on_csv_row' do
    let(:pending_case) {true}
    it 'leaves the row unchanged' do
      event_row = {
        case_number: '2005-CM-0012',
        charge: '9876 - Not a good thing - Class: 4',
        disposition: 'Dismissed'
      }
      event = Arrest.new(
        dcn: '2005-CM-0012',
        arresting_agency_code: 'Toon County Sheriff',
        code: '9876',
        description: 'Not a good thing',
        dispositions: nil,
      )

      event_hash = event.set_expungement_eligibility_on_csv_row(event_row, false)

      expect(event_hash).to eq({
                                 case_number: '2005-CM-0012',
                                 charge: '9876 - Not a good thing - Class: 4',
                                 disposition: 'Dismissed',
                               })
    end
  end

  describe 'set_sealable_eligibility_on_csv_row' do
    it 'leaves the row unchanged' do
      row = {
        case_number: '2005-CM-0012',
        charge: '9876 - Not a good thing - Class: 4',
        disposition: 'Guilty'
      }
      event = Arrest.new(
        dcn: '2005-CM-0012',
        arresting_agency_code: 'Toon County Sheriff',
        code: '9876',
        description: 'Not a good thing',
        dispositions: nil,
      )

      hash = event.set_sealable_eligibility_on_csv_row(row, false)

      expect(hash).to eq({
                           case_number: '2005-CM-0012',
                           charge: '9876 - Not a good thing - Class: 4',
                           disposition: 'Guilty',
                         })
    end
  end

  describe 'set_disqualified_eligibility_on_csv_row' do
    it 'leaves the row unchanged' do
      row = {
        case_number: '2005-CM-0012',
        charge: '625 5/11-501 - DUI - Class: 4',
        disposition: 'Guilty'
      }
      event = Arrest.new(
        dcn: '2005-CM-0012',
        arresting_agency_code: 'Toon County Sheriff',
        code: '9876',
        description: 'Not a good thing',
        dispositions: nil,
      )

      hash = event.set_disqualified_eligibility_on_csv_row(row)

      expect(hash).to eq({
                           case_number: '2005-CM-0012',
                           charge: '625 5/11-501 - DUI - Class: 4',
                           disposition: 'Guilty'
                         })
    end
  end
end
