# frozen_string_literal: true

require "test_helper"

class ReferenceBookTest < ActiveSupport::TestCase
  test "valid reference_book" do
    book = reference_books(:reference_book1)
    assert book["practice_id"].present?
  end
end
