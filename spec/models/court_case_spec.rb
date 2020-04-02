require_relative '../../models/court_case'
require_relative '../../models/charge'
require_relative '../../models/disposition'

RSpec.describe CourtCase do
  describe 'type' do
    it 'returns :court_case' do
      expect(CourtCase.new.type).to eq(:court_case)
    end
  end
  describe 'all_expungable?' do
    context 'when all the events are dismissals or acquittals' do
      it 'returns true' do
        event1 = Charge.new(dispositions: [Disposition.new(description: 'Dismissed')])
        event2 = Charge.new(dispositions: [Disposition.new(description: 'Dismiss/State Motion')])
        event3 = Charge.new(dispositions: [Disposition.new(description: 'Not Guilty')])
        court_case = CourtCase.new(case_number: '12345', events: [event1, event2, event3])

        expect(court_case.all_expungable?).to eq(true)
      end
    end

    context 'when at least one event is some other type of disposition' do
      it 'returns false' do
        event1 = Charge.new(dispositions: [Disposition.new(description: 'Dismissed')])
        event2 = Charge.new(dispositions: [Disposition.new(description: 'Guilty')])
        event3 = Charge.new(dispositions: [Disposition.new(description: 'Not Guilty')])
        court_case = CourtCase.new(case_number: '12345', events: [event1, event2, event3])

        expect(court_case.all_expungable?).to eq(false)
      end
    end
  end
end