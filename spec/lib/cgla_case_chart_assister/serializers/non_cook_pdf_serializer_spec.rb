require 'cgla_case_chart_assister/serializers/non_cook_pdf_serializer'
require 'cgla_case_chart_assister/models/charge'
require 'cgla_case_chart_assister/models/disposition'

RSpec.describe CglaCaseChartAssister::NonCookPDFSerializer do
  describe 'basic_case_chart_hash' do
    it 'returns a hash of the basic case chart information for the given index' do
      event = CglaCaseChartAssister::Charge.new(
        case_number: '2005-CM-0012',
        arresting_agency_code: 'Toon County Sheriff',
        code: '9876',
        description: 'Not a good thing',
        offense_type: 'F',
        offense_class: '4',
        dispositions: [
          CglaCaseChartAssister::Disposition.new(
            description: 'Not Guilty',
            date: '10-Oct-2005',
            sentence_description: 'No Sentence'
          )
        ]
      )

      hash = CglaCaseChartAssister::NonCookPDFSerializer.serialize_event(4, event)
      expect(hash).to eq({
                           "4_case_number": '2005-CM-0012',
                           "4_charges": '9876 - Not a good thing',
                           "4_fmqt": 'F',
                           "4_class": '4',
                           "4_disposition_date": "Not Guilty\n10-Oct-2005",
                           "4_sentence": 'No Sentence',
                           "4_other_notes": "Toon County Sheriff\n"
                         })
    end
  end

  describe 'pre_jano_case_chart_hash' do
    it 'returns a hash of some basic and eligibility case chart information for the given index' do
      event = CglaCaseChartAssister::Charge.new(
        case_number: '2005-CM-0012',
        arresting_agency_code: 'Toon County Sheriff',
        code: '',
        description: 'Breaking and entering',
        offense_type: nil,
        offense_class: nil,
        dispositions: [
          CglaCaseChartAssister::Disposition.new(
            description: 'Pre-JANO Disposition',
            date: '10-Oct-2005',
            sentence_description: 'Pre-JANO Sentence'
          )
        ]
      )

      hash = CglaCaseChartAssister::NonCookPDFSerializer.serialize_pre_jano_event(4, event)
      expect(hash).to eq({
                           "4_disposition_date": "\n10-Oct-2005",
                           "4_sentence": nil,
                           "4_is_eligible": nil,
                           "4_is_conviction": nil,
                           "4_other_notes": "Toon County Sheriff\nPre-JANO disposition. Requires manual records check.",
                         })
    end
  end

  describe 'expungement_case_chart_hash' do
    context 'when pending_case is false' do
      let(:pending_case) {false}
      it 'returns a hash of eligibility case chart information for the given disposition type and index' do
        dismissal = CglaCaseChartAssister::Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              CglaCaseChartAssister::Disposition.new(
                  description: 'Dismissed',
                  date: '10-Oct-2005',
                  sentence_description: 'No Sentence'
              )
          ]
        )

        acquittal = CglaCaseChartAssister::Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
              CglaCaseChartAssister::Disposition.new(
                  description: 'Not Guilty',
                  date: '10-Oct-2005',
                  sentence_description: 'No Sentence'
              )
          ]
        )

        dismissal_hash = CglaCaseChartAssister::NonCookPDFSerializer.serialize_expungement_event(2, dismissal,pending_case)
        acquittal_hash = CglaCaseChartAssister::NonCookPDFSerializer.serialize_expungement_event(2, acquittal, pending_case)

        expect(dismissal_hash).to eq({
                                       "2_is_eligible": 'E',
                                       "2_is_conviction": 'N',
                                       "2_discharge_date": 'N/A',
                                       "2_other_notes": "Toon County Sheriff\nExpunge if no pending cases in other counties. (Dismissal)",
                                     })

        expect(acquittal_hash).to eq({
                                       "2_is_eligible": 'E',
                                       "2_is_conviction": 'N',
                                       "2_discharge_date": 'N/A',
                                       "2_other_notes": "Toon County Sheriff\nExpunge if no pending cases in other counties. (Acquittal)",
                                     })
      end
    end

    context 'when pending_case is true' do
      let(:pending_case) {true}
      it 'returns a hash of eligibility case chart information for the given index with eligible false' do
        event = CglaCaseChartAssister::Charge.new(
          case_number: '2005-CM-0012',
          arresting_agency_code: 'Toon County Sheriff',
          code: '9876',
          description: 'Not a good thing',
          offense_type: 'F',
          offense_class: '4',
          dispositions: [
            CglaCaseChartAssister::Disposition.new(
              description: 'Dismissed',
              date: '10-Oct-2005',
              sentence_description: 'No Sentence'
            )
          ]
        )

        hash = CglaCaseChartAssister::NonCookPDFSerializer.serialize_expungement_event(2, event, pending_case)
        expect(hash).to eq({
                             "2_is_eligible": 'N',
                             "2_is_conviction": 'N',
                             "2_discharge_date": 'N/A',
                             "2_other_notes": "Toon County Sheriff\nPending case in Champaign Co. Expunge once no cases are pending. (Dismissal)",
                           })
      end
    end
  end
end