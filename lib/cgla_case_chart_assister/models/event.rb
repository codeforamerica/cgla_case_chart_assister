# An abstract base class for Charge and Arrest
# Not to be used on its own
module CglaCaseChartAssister
  class Event
    def initialize(
        index: nil,
        case_number: nil,
        date_filed: nil,
        arresting_agency_code: nil,
        dcn: nil,
        code: nil,
        description: nil,
        offense_type: nil,
        offense_class: nil,
        dispositions: []
    )

      @index = index
      @case_number = case_number
      @date_filed = date_filed
      @arresting_agency_code = arresting_agency_code
      @dcn = dcn
      @code = code
      @description = description
      @offense_type = offense_type
      @offense_class = offense_class
      @dispositions = dispositions
    end

    attr_reader :index, :case_number, :date_filed, :arresting_agency_code, :dcn,
                :code, :description, :offense_type, :offense_class, :dispositions
  end
end