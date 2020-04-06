require 'cgla_case_chart_assister/models/charge'
require 'cgla_case_chart_assister/models/disposition'
require 'cgla_case_chart_assister/models/history'

RSpec.describe CglaCaseChartAssister::History do
  let(:history) {CglaCaseChartAssister::History.new}

  describe 'type' do
    it 'returns :history' do
      expect(history.type).to eq(:history)
    end
  end

  describe 'has_pending_case?' do
    context 'when any charge is pending' do
      it' returns true' do
        history.events = [CglaCaseChartAssister::Charge.new(dispositions: [])]

        expect(history.has_pending_case?).to eq(true)
      end
    end


    context 'when any charge is pending' do
      it' returns true' do
        history.events = [CglaCaseChartAssister::Charge.new(dispositions: [
          CglaCaseChartAssister::Disposition.new(description: nil, date: nil)
        ])]

        expect(history.has_pending_case?).to eq(true)
      end
    end
  end
end
