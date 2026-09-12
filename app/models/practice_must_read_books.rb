# frozen_string_literal: true

class PracticeMustReadBooks
  def initialize(practice)
    @practice = practice
  end

  def include_must_read_books?
    return false if @practice.practices_books.empty?

    @practice.practices_books.any?(&:must_read)
  end
end
