require 'cgla_case_chart_assister/models/disposition'

RSpec.describe CglaCaseChartAssister::Disposition do
  let(:disposition) {CglaCaseChartAssister::Disposition.new}

  describe 'type' do
    it 'returns :disposition' do
      expect(disposition.type).to eq(:disposition)
    end
  end
end
