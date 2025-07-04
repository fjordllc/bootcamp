# frozen_string_literal: true

class GrassDateParamater
  def initialize(params)
    @params = params
  end

  def target_end_date
    return Date.current if @params.blank?

    return Date.current unless @params.match?(/\A\d{4}-\d{2}-\d{2}\z/)

    Date.parse(@params)
  rescue Date::Error
    Date.current
  end
end
