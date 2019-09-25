History = Struct.new(:person_name, :ir_number, :dob, :events, keyword_init: true) do
  def pending_case?
    # TBD, Active status does not seem to be the right way to determine this
    # history.each do |event|
    #   if event[:status_description] == 'Active'
    #     @logger.info "#{event[:individual]} has a pending case"
    #     return true
    #   end
    # end
    false
  end

  def case_chart_headers_hash
    {client_name: person_name, IR_number: ir_number, dob: dob}
  end
end