require 'cgla_case_chart_assister/models/arrest'

RSpec.describe CglaCaseChartAssister::Arrest do
  let(:arrest) {CglaCaseChartAssister::Arrest.new}

  describe 'attributes' do
    it 'has default attributes' do
      event = CglaCaseChartAssister::Arrest.new

      expect(event.dispositions).to match_array([])
    end

    it 'makes attributes available on instance' do
      event = CglaCaseChartAssister::Arrest.new(
          index: 1,
          case_number: 'case12345',
          date_filed: '15-Oct-2019',
          arresting_agency_code: 'arrest-123',
          dcn: 'dcn123',
          code: 'statute 1',
          description: 'my charge',
          offense_type: 'felony',
          offense_class: 'class 4',
          dispositions: ['foo']
      )

      expect(event.index).to eq(1)
      expect(event.case_number).to eq('case12345')
      expect(event.date_filed).to eq('15-Oct-2019')
      expect(event.arresting_agency_code).to eq('arrest-123')
      expect(event.dcn).to eq('dcn123')
      expect(event.code).to eq('statute 1')
      expect(event.description).to eq('my charge')
      expect(event.offense_type).to eq('felony')
      expect(event.offense_class).to eq('class 4')
      expect(event.dispositions.count).to eq(1)
    end
  end

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
end
