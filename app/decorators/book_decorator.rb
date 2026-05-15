# frozen_string_literal: true

module BookDecorator
  def must_read_for_any_practices?
    practices_books.any?(&:must_read)
  end
end
