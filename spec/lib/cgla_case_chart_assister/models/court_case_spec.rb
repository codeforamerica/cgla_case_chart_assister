require 'cgla_case_chart_assister/models/court_case'
require 'cgla_case_chart_assister/models/event'

RSpec.describe CglaCaseChartAssister::CourtCase do
  describe 'all_expungable?' do
    context 'when all the events are dismissals or acquittals' do
      it 'returns true' do
        event1 = CglaCaseChartAssister::Event.new(disposition: 'Dismissed', case_number: '12345')
        event2 = CglaCaseChartAssister::Event.new(disposition: 'Dismiss/State Motion', case_number: '12345')
        event3 = CglaCaseChartAssister::Event.new(disposition: 'Not Guilty', case_number: '12345')
        court_case = CglaCaseChartAssister::CourtCase.new(case_number: '12345', events: [event1, event2, event3])

        expect(court_case.all_expungable?).to eq(true)
      end
    end

    context 'when at least one event is some other type of disposition' do
      it 'returns false' do
        event1 = CglaCaseChartAssister::Event.new(disposition: 'Dismissed', case_number: '12345')
        event3 = CglaCaseChartAssister::Event.new(disposition: 'Not Guilty', case_number: '12345')
        event2 = CglaCaseChartAssister::Event.new(disposition: 'Guilty', case_number: '12345')
        court_case = CglaCaseChartAssister::CourtCase.new(case_number: '12345', events: [event1, event2, event3])

        expect(court_case.all_expungable?).to eq(false)
      end
    end
  end
end