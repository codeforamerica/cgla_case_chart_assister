require 'cgla_case_chart_assister/models/disposition'

RSpec.describe CglaCaseChartAssister::Disposition do
  it 'makes attributes available on instance' do
    disposition = CglaCaseChartAssister::Disposition.new(
      case_number: 'case1235',
      charge_index: '1',
      description: 'Final disposition',
      date: '15-Oct-2005',
      sentence_description: 'A sentence',
      sentence_duration: '5 years'
    )
    expect(disposition.case_number).to eq('case1235')
    expect(disposition.charge_index).to eq('1')
    expect(disposition.description).to eq('Final disposition')
    expect(disposition.date).to eq('15-Oct-2005')
    expect(disposition.sentence_description).to eq('A sentence')
    expect(disposition.sentence_duration).to eq('5 years')
  end
end
