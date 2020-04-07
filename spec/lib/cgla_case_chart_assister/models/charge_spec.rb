require 'date'

require 'cgla_case_chart_assister/models/charge'
require 'cgla_case_chart_assister/models/disposition'

RSpec.describe CglaCaseChartAssister::Charge do
  describe 'attributes' do
    it 'has default attributes' do
      event = CglaCaseChartAssister::Charge.new

      expect(event.dispositions).to match_array([])
    end

    it 'makes attributes available on instance' do
      event = CglaCaseChartAssister::Charge.new(
        index: 1,
        case_number: 'case12345',
        date_filed: '15-Oct-2019',
        arresting_agency_code: 'arrest-123',
        dcn: 'dcn123',
        code: 'statute 1',
        description: 'my charge',
        offense_type: 'felony',
        offense_class: 'class 4',
        dispositions: ['foo']
      )

      expect(event.index).to eq(1)
      expect(event.case_number).to eq('case12345')
      expect(event.date_filed).to eq('15-Oct-2019')
      expect(event.arresting_agency_code).to eq('arrest-123')
      expect(event.dcn).to eq('dcn123')
      expect(event.code).to eq('statute 1')
      expect(event.description).to eq('my charge')
      expect(event.offense_type).to eq('felony')
      expect(event.offense_class).to eq('class 4')
      expect(event.dispositions.count).to eq(1)
    end
  end

  describe '#pending_case?' do
    it 'returns true when neither disposition nor disposition date are populated' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: nil, date: nil)]
      )
      expect(event.pending_case?).to eq(true)
    end

    it 'returns false when disposition or disposition_date or both are populated' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: 'disposition', date: Date.today)]
      )
      expect(event.pending_case?).to eq(false)
    end
  end

  describe 'pre_JANO?' do
    it 'returns true when the disposition is pre-JANO' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: 'Pre-JANO Disposition')]
      )
      expect(event.pre_JANO?).to eq(true)
    end

    it 'returns false when the disposition is anything else' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: 'blah')]
      )
      expect(event.pre_JANO?).to eq(false)
    end
  end

  describe 'dismissed?' do
    it 'returns true when any disposition is some form of dismissal' do
      event1 = CglaCaseChartAssister::Charge.new(dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Dismissed')
      ])
      event2 = CglaCaseChartAssister::Charge.new(dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Dismiss/State Motion')
      ])
      event3 = CglaCaseChartAssister::Charge.new(dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Dismiss/Want of Prosecution')
      ])
      expect(event1.dismissed?).to eq(true)
      expect(event2.dismissed?).to eq(true)
      expect(event3.dismissed?).to eq(true)
    end

    it 'returns false if the disposition description is empty' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: nil)]
      )
      expect(event.dismissed?).to eq(false)
    end

    it 'returns false when the disposition description is anything else' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: 'my fake disposition')]
      )
      expect(event.dismissed?).to eq(false)
    end
  end

  describe 'acquitted?' do
    it 'returns true when the disposition is Not Guilty' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: 'Not Guilty')]
      )
      expect(event.acquitted?).to eq(true)
    end

    it 'returns false if the disposition description is empty' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: nil)]
      )
      expect(event.dismissed?).to eq(false)
    end

    it 'returns false when the disposition is anything else' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: 'my fake disposition')]
      )
      expect(event.acquitted?).to eq(false)
    end
  end

  describe 'conviction?' do
    it 'returns true when the disposition is Guilty' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: 'Guilty')]
      )
      expect(event.conviction?).to eq(true)
    end

    it 'returns false if the disposition description is empty' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: nil)]
      )
      expect(event.dismissed?).to eq(false)
    end

    it 'returns false when the disposition is anything else' do
      event = CglaCaseChartAssister::Charge.new(
        dispositions: [CglaCaseChartAssister::Disposition.new(description: 'my fake disposition')]
      )
      expect(event.conviction?).to eq(false)
    end
  end

  describe 'eligible_for_sealing?' do
    context 'when the offense the is "T" (traffic)' do
      it 'returns false' do
        event = CglaCaseChartAssister::Charge.new(code: '720 5/anything', offense_type: 'T', dispositions: [
            CglaCaseChartAssister::Disposition.new(description: 'Guilty')
        ])
        expect(event.eligible_for_sealing?).to eq(false)
      end
    end

    it 'returns true when the charge code is eligible' do
      event = CglaCaseChartAssister::Charge.new(code: '720 5/anything', offense_type: 'M', dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Guilty')
      ])
      expect(event.eligible_for_sealing?).to eq(true)
    end

    it 'returns false when the charge code is NOT eligible' do
      event = CglaCaseChartAssister::Charge.new(code: '720 5/48-1', offense_type: 'M', dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Guilty')
      ])
      expect(event.eligible_for_sealing?).to eq(false)
    end
  end

  describe 'eligible_for_expungement?' do
    context 'when the offense the is "T" (traffic)' do
      it 'returns false when the event was dismissed' do
        event = CglaCaseChartAssister::Charge.new(offense_type: 'T', dispositions: [
            CglaCaseChartAssister::Disposition.new(description: 'Dismissed')
        ])
        expect(event.eligible_for_expungement?).to eq(false)
      end

      it 'returns false when the event was acquitted' do
        event = CglaCaseChartAssister::Charge.new(offense_type: 'T', dispositions: [
            CglaCaseChartAssister::Disposition.new(description: 'Not Guilty')
        ])
        expect(event.eligible_for_expungement?).to eq(false)
      end
    end

    it 'returns true when the event was dismissed' do
      event = CglaCaseChartAssister::Charge.new(offense_type: 'F', dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Dismissed')
      ])
      expect(event.eligible_for_expungement?).to eq(true)
    end

    it 'returns true when the event was acquitted' do
      event = CglaCaseChartAssister::Charge.new(offense_type: 'F', dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'Not Guilty')
      ])
      expect(event.eligible_for_expungement?).to eq(true)
    end

    it 'returns false when the disposition is anything else' do
      event = CglaCaseChartAssister::Charge.new(offense_type: 'F', dispositions: [
          CglaCaseChartAssister::Disposition.new(description: 'some other thing')
      ])
      expect(event.eligible_for_expungement?).to eq(false)
    end
  end

  describe 'sealable_code_section?' do
    it 'returns false if the code section is a victims compensation charge' do
      event = CglaCaseChartAssister::Charge.new(code: '740 45/2(c)')
      expect(event.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a dui charge' do
      event = CglaCaseChartAssister::Charge.new(code: '625 5/11-501')
      expect(event.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a reckless driving charge charge' do
      event = CglaCaseChartAssister::Charge.new(code: '625 5/11-503')
      expect(event.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is an animal cruelty charge' do
      event = CglaCaseChartAssister::Charge.new(code: '510 70/1-anything')
      expect(event.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a dog fighting charge' do
      event1 = CglaCaseChartAssister::Charge.new(code: '720 5/26-5')
      event2 = CglaCaseChartAssister::Charge.new(code: '720 5/48-1')
      expect(event1.sealable_code_section?).to eq(false)
      expect(event2.sealable_code_section?).to eq(false)      end

    it 'returns false if the code section is a domestic battery charge charge' do
      event1 = CglaCaseChartAssister::Charge.new(code: '720 5/12-3.1')
      event2 = CglaCaseChartAssister::Charge.new(code: '720 5/12-3.2(a)(2)')
      expect(event1.sealable_code_section?).to eq(false)
      expect(event2.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a no contact violation charge' do
      event1 = CglaCaseChartAssister::Charge.new(code: '740 21/anything')
      event2 = CglaCaseChartAssister::Charge.new(code: '740 22/anything')
      expect(event1.sealable_code_section?).to eq(false)
      expect(event2.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a sex abuse charge charge' do
      event1 = CglaCaseChartAssister::Charge.new(code: '720 5/12-15')
      event2 = CglaCaseChartAssister::Charge.new(code: '720 5/12-3.4')
      event3 = CglaCaseChartAssister::Charge.new(code: '720 5/12-30')
      expect(event1.sealable_code_section?).to eq(false)
      expect(event2.sealable_code_section?).to eq(false)
      expect(event3.sealable_code_section?).to eq(false)
    end

    it 'returns false if the code section is a sex crimes charge charge' do
      event1 = CglaCaseChartAssister::Charge.new(code: '720 5/11-15')
      event2 = CglaCaseChartAssister::Charge.new(code: '720 5/11-1(a)')
      event3 = CglaCaseChartAssister::Charge.new(code: '720 5/11-anything')
      expect(event1.sealable_code_section?).to eq(false)
      expect(event2.sealable_code_section?).to eq(false)
      expect(event3.sealable_code_section?).to eq(false)
    end

    it 'returns true if the code section is an exempted sex crimes charge' do
      event1 = CglaCaseChartAssister::Charge.new(code: '720 5/11-14')
      event2 = CglaCaseChartAssister::Charge.new(code: '720 5/11-30')
      expect(event1.sealable_code_section?).to eq(true)
      expect(event2.sealable_code_section?).to eq(true)
    end

    it 'returns true if the code section is any other charge' do
      event = CglaCaseChartAssister::Charge.new(code: '720 5/anything')
      expect(event.sealable_code_section?).to eq(true)
    end
  end
end
