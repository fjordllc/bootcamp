# frozen_string_literal: true

module DateParsable
  extend ActiveSupport::Concern

  private

  def parse_target_end_date
    return Date.current unless params[:end_date].present?

    Date.parse(params[:end_date])
  rescue Date::Error
    Date.current
  end
end