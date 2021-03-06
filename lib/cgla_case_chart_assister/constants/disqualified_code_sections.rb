module CglaCaseChartAssister
  VICTIMS_COMPENSATION_CODE_SECTION_MATCHER = /740 45\/2\(c\).*/
  DUI_SECTION_MATCHER = /625 5\/11-501.*/
  RECKLESS_DRIVING_CODE_SECTION_MATCHER = /625 5\/11-503.*/
  ANIMAL_CRUELTY_CODE_SECTION_MATCHER = /510 70\/1.*/
  DOG_FIGHTING_CODE_SECTION_MATCHER = /720 5\/(26-5|48-1).*/
  DOMESTIC_BATTERY_CODE_SECTIONS_MATCHER = /720 5\/12-3\.[12].*/
  NO_CONTACT_CODE_SECTIONS_MATCHER = /740 2[12]\/.*/
  SEX_CRIME_CODE_SECTIONS_MATCHER = /720 5\/11-(?<subsection>.*)/
  SEX_ABUSE_CODE_SECTIONS_MATCHER = /720 5\/12-(15|3\.4|30).*/
  ALLOWED_SEX_CRIME_SUBSECTIONS = ['14', '30']
end