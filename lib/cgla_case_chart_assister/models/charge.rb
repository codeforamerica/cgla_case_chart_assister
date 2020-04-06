require 'cgla_case_chart_assister/constants/disqualified_code_sections'

module CglaCaseChartAssister
  # A charge only occurs for court cases (not arrests)
  Charge = Struct.new(
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
      :charge
    end

    def pending_case?
      dispositions&.all?{|disposition| disposition.description.nil? && disposition.date.nil? }
    end

    def pre_JANO?
      dispositions&.any?{|disposition| disposition.description == 'Pre-JANO Disposition' }
    end

    def dismissed?
      dispositions&.any?{|disposition| disposition.description && disposition.description.start_with?('Dismiss') }
    end

    def acquitted?
      dispositions&.any?{|disposition| disposition.description == 'Not Guilty' }
    end

    def conviction?
      dispositions&.any?{|disposition| disposition.description == 'Guilty' }
    end

    def fill_eligibility_info?
      dismissed? || acquitted? || conviction?
    end

    def sealable_code_section?
      !(VICTIMS_COMPENSATION_CODE_SECTION_MATCHER.match(code) ||
        DUI_SECTION_MATCHER.match(code) ||
        RECKLESS_DRIVING_CODE_SECTION_MATCHER.match(code) ||
        ANIMAL_CRUELTY_CODE_SECTION_MATCHER.match(code) ||
        DOG_FIGHTING_CODE_SECTION_MATCHER.match(code) ||
        DOMESTIC_BATTERY_CODE_SECTIONS_MATCHER.match(code) ||
        NO_CONTACT_CODE_SECTIONS_MATCHER.match(code) ||
        SEX_ABUSE_CODE_SECTIONS_MATCHER.match(code) ||
        disqualified_sex_crime?)
    end

    def disqualified_sex_crime?
      match_result = SEX_CRIME_CODE_SECTIONS_MATCHER.match(code)
      !(match_result.nil? ||
        ALLOWED_SEX_CRIME_SUBSECTIONS.include?(match_result[:subsection]))
    end

    def eligible_for_expungement?
      (dismissed? || acquitted?) && offense_type != 'T'
    end

    def eligible_for_sealing?
      sealable_code_section? && offense_type != 'T'
    end

    def arresting_agency
      arresting_agency_code || 'Agency Not Provided'
    end

    def expungement_type
      if dismissed?
        '(Dismissal)'
      elsif acquitted?
        '(Acquittal)'
      end
    end
  end
end