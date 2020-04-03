require 'cgla_case_chart_assister/models/court_case'
require 'cgla_case_chart_assister/models/charge'
require 'cgla_case_chart_assister/models/disposition'

RSpec.describe CglaCaseChartAssister::CourtCase do
  describe 'type' do
    it 'returns :court_case' do
      expect(CglaCaseChartAssister::CourtCase.new.type).to eq(:court_case)
    end
  end

  describe 'all_expungable?' do
    context 'when all the charges are dismissals or acquittals' do
      it 'returns true' do
        event1 = CglaCaseChartAssister::Charge.new(dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Dismissed')
        ])
        event2 = CglaCaseChartAssister::Charge.new(dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Dismiss/State Motion')
        ])
        event3 = CglaCaseChartAssister::Charge.new(dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Not Guilty')
        ])
        court_case = CglaCaseChartAssister::CourtCase.new(case_number: '12345', charges: [event1, event2, event3])

        expect(court_case.all_expungable?).to eq(true)
      end
    end

    context 'when at least one event is some other type of disposition' do
      it 'returns false' do
        event1 = CglaCaseChartAssister::Charge.new(dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Dismissed')
        ])
        event2 = CglaCaseChartAssister::Charge.new(dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Guilty')
        ])
        event3 = CglaCaseChartAssister::Charge.new(dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Not Guilty')
        ])
        court_case = CglaCaseChartAssister::CourtCase.new(case_number: '12345', charges: [event1, event2, event3])

        expect(court_case.all_expungable?).to eq(false)
      end
    end
  end

  describe 'cannot_determine_sealing?' do
    context 'when any charges a nil charge code' do
      it 'returns true' do
        event1 = CglaCaseChartAssister::Charge.new(code: nil)
        event2 = CglaCaseChartAssister::Charge.new(code: 'asdf')
        court_case = CglaCaseChartAssister::CourtCase.new(charges: [event1, event2])

        expect(court_case.cannot_determine_sealing?).to eq(true)
      end
    end

    context 'when any charges have an empty string charge code' do
      it 'returns true' do
        event1 = CglaCaseChartAssister::Charge.new(code: '')
        event2 = CglaCaseChartAssister::Charge.new(code: 'asdf')
        court_case = CglaCaseChartAssister::CourtCase.new(charges: [event1, event2])

        expect(court_case.cannot_determine_sealing?).to eq(true)
      end
    end

    context 'when all charges have a charge code' do
      it 'returns false' do
        event1 = CglaCaseChartAssister::Charge.new(code: 'hello')
        event2 = CglaCaseChartAssister::Charge.new(code: 'asdf')
        court_case = CglaCaseChartAssister::CourtCase.new(charges: [event1, event2])

        expect(court_case.cannot_determine_sealing?).to eq(false)
      end
    end
  end
end