require_relative '../../models/court_case'
require_relative '../../models/charge'

RSpec.describe CourtCase do
  describe 'all_expungable?' do
    context 'when all the events are dismissals or acquittals' do
      it 'returns true' do
        event1 = Charge.new(disposition: 'Dismissed', case_number: '12345')
        event2 = Charge.new(disposition: 'Dismiss/State Motion', case_number: '12345')
        event3 = Charge.new(disposition: 'Not Guilty', case_number: '12345')
        court_case = CourtCase.new(case_number: '12345', events: [event1, event2, event3])

        expect(court_case.all_expungable?).to eq(true)
      end
    end

    context 'when at least one event is some other type of disposition' do
      it 'returns false' do
        event1 = Charge.new(disposition: 'Dismissed', case_number: '12345')
        event3 = Charge.new(disposition: 'Not Guilty', case_number: '12345')
        event2 = Charge.new(disposition: 'Guilty', case_number: '12345')
        court_case = CourtCase.new(case_number: '12345', events: [event1, event2, event3])

        expect(court_case.all_expungable?).to eq(false)
      end
    end
  end
end