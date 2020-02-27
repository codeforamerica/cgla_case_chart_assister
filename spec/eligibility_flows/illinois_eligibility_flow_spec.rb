require_relative '../../eligibility_flows/illinois_eligibility_flow'
require_relative '../../updaters/eligibility_updater'

RSpec.describe IllinoisEligibilityFlow do
  let(:subject) {IllinoisEligibilityFlow.new}

  describe '#populate_eligibility' do
    let(:row) {double('row')}
    let(:event) {double('event')}
    let(:court_case) {double('court_case')}
    let(:history) {double('history')}

    before do
      allow(event).to receive(:case_number) {1234}
      allow(court_case).to receive(:case_number) {1234}
      allow(history).to receive(:court_cases) {[court_case]}
      allow(history).to receive(:has_pending_case?) {false}
      allow(EligibilityUpdater).to receive(:apply_expungement_eligibility)
      allow(EligibilityUpdater).to receive(:apply_undetermined_eligibility)
      allow(EligibilityUpdater).to receive(:apply_sealable_eligibility)
      allow(EligibilityUpdater).to receive(:apply_disqualified_eligibility)
    end

    context 'when the event does not qualify for analysis' do
      before do
        allow(event).to receive(:fill_eligibility_info?) {false}
      end

      it 'returns the original row without further analysis' do
        expect(court_case).not_to receive(:all_expungable?) {true}
        subject.populate_eligibility(row, event, history)
      end
    end

    context 'when all events in the case are eligible for expungement' do
      before do
        allow(event).to receive(:fill_eligibility_info?) {true}
        allow(court_case).to receive(:all_expungable?) {true}
      end

      it 'sets expungement info on the row' do
        expect(EligibilityUpdater).to receive(:apply_expungement_eligibility)
        subject.populate_eligibility(row, event, history)
      end
    end

    context 'when at least one event is not eligible for expungement and sealing eligibility cannot be determined' do
      before do
        allow(event).to receive(:fill_eligibility_info?) {true}
        allow(court_case).to receive(:all_expungable?) {false}
        allow(court_case).to receive(:cannot_determine_sealing?) {true}
      end

      it 'sets undetermined info on row' do
        expect(EligibilityUpdater).to receive(:apply_undetermined_eligibility)
        subject.populate_eligibility(row, event, history)
      end
    end

    context 'when at least one event is not eligible for expungement but all events in the case are eligible for sealing' do
      before do
        allow(event).to receive(:fill_eligibility_info?) {true}
        allow(court_case).to receive(:all_expungable?) {false}
        allow(court_case).to receive(:cannot_determine_sealing?) {false}
        allow(court_case).to receive(:all_sealable?) {true}
      end

      it 'sets sealing info on the row' do
        expect(EligibilityUpdater).to receive(:apply_sealable_eligibility)
        subject.populate_eligibility(row, event, history)
      end
    end

    context 'when at least one event is not eligible for sealing and all events were analyzed' do
      before do
        allow(event).to receive(:fill_eligibility_info?) {true}
        allow(court_case).to receive(:all_expungable?) {false}
        allow(court_case).to receive(:cannot_determine_sealing?) {false}
        allow(court_case).to receive(:all_sealable?) {false}
      end

      it 'sets disqualified info on the row' do
        expect(EligibilityUpdater).to receive(:apply_disqualified_eligibility)
        subject.populate_eligibility(row, event, history)
      end
    end
  end
end
