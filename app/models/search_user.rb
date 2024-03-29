# frozen_string_literal: true

class SearchUser
  attr_reader :search_word

  def initialize(search_word:, users: nil, target: nil, require_retire_user: false)
    @users = users
    @search_word = validate_search_word(search_word)
    @target = target
    @require_retire_user = require_retire_user
  end

  def search
    searched_user = @users ? @users.search_by_keywords(word: @search_word) : User.search_by_keywords({ word: @search_word })

    if @target == 'retired'
      searched_user.unscope(where: :retired_on).retired
    elsif @require_retire_user
      searched_user.unscope(where: :retired_on)
    else
      searched_user
    end
  end

  private

  def validate_search_word(search_word)
    stripped_word = search_word.strip
    if stripped_word.match?(/^[\w-]+$/)
      stripped_word if stripped_word.length >= 3
    elsif stripped_word.length >= 2
      stripped_word
    end
  end
end
