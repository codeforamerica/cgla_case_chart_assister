require 'cgla_case_chart_assister/models/charge'
require 'cgla_case_chart_assister/models/disposition'
require 'cgla_case_chart_assister/models/history'

RSpec.describe CglaCaseChartAssister::History do
  describe 'attributes' do
    it 'has default attributes' do
      history = CglaCaseChartAssister::History.new

      expect(history.events).to match_array([])
      expect(history.court_cases).to match_array([])
    end

    it 'makes attributes available on instance' do
      history = CglaCaseChartAssister::History.new(
        person_name: 'jane doe',
        ir_number: '1234',
        dob: '12-Oct-2005',
        events: ['fake event'],
        court_cases: ['fake case one', 'fake case two']
      )

      expect(history.person_name).to eq('jane doe')
      expect(history.ir_number).to eq('1234')
      expect(history.dob).to eq('12-Oct-2005')
      expect(history.events.count).to eq(1)
      expect(history.court_cases.count).to eq(2)
    end
  end

  describe 'has_pending_case?' do
    context 'when any charge is pending' do
      it' returns true' do
        history = CglaCaseChartAssister::History.new(events: [
          CglaCaseChartAssister::Charge.new(dispositions: [])
        ])

        expect(history.has_pending_case?).to eq(true)
      end
    end

    context 'when any charge is pending' do
      it' returns true' do
        history = CglaCaseChartAssister::History.new(events: [
          CglaCaseChartAssister::Charge.new(dispositions: [
            CglaCaseChartAssister::Disposition.new(description: nil, date: nil)
          ])
        ])

        expect(history.has_pending_case?).to eq(true)
      end
    end
  end
end
