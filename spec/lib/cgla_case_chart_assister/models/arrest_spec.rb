require 'cgla_case_chart_assister/models/arrest'

RSpec.describe CglaCaseChartAssister::Arrest do
  let(:arrest) {CglaCaseChartAssister::Arrest.new}

  describe "type" do
    it 'returns :arrest' do
      expect(arrest.type).to eq(:arrest)
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
