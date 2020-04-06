require 'cgla_case_chart_assister/constants/disqualified_code_sections'

module CglaCaseChartAssister
  Arrest = Struct.new(
    :index,
    :central_booking_number,
    :case_number,
    :date_filed,
    :arresting_agency_code,
    :dcn,
    :code,
    :description,
    :offense_type,
    :offense_class,
    :dispositions,
    keyword_init: true) do

    def type
      :arrest
    end

    def pending_case?
      false
    end

    def pre_JANO?
      false
    end

    def dismissed?
      false
    end

    def acquitted?
      false
    end

    def conviction?
      false
    end

    def fill_eligibility_info?
      false
    end

    def sealable_code_section?
      # Arrests are not sealable by code section
      false
    end

    def disqualified_sex_crime?
      false
    end

    def eligible_for_expungement?
      false
    end

    def eligible_for_sealing?
      false
    end

    def arresting_agency
      arresting_agency_code || 'Agency Not Provided'
    end
  end
end