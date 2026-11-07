# frozen_string_literal: true

class API::Pagination
  attr_reader :page, :per_page

  def initialize(params)
    @page = parse(params.fetch(:page, '1'), 1_000_000)
    @per_page = parse(params.fetch(:per_page, '20'), 100)
  end

  def valid?
    page.present? && per_page.present?
  end

  def offset
    (page - 1) * per_page
  end

  private

  def parse(value, maximum)
    return unless value.is_a?(String) && value.match?(/\A[1-9][0-9]{0,6}\z/)

    number = value.to_i
    number if number <= maximum
  end
end
