# frozen_string_literal: true

class SearchablesComponent < ViewComponent::Base
  def initialize(searchables:, users:, word:, talks:)
    @searchables = searchables
    @users = users
    @word = word
    @talks = talks
  end

  private

  attr_reader :searchables, :users, :word, :talks
end
