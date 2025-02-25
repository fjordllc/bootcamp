# frozen_string_literal: true

class SearchUser
  def initialize(word:, users: nil, target: nil, require_retire_user: false)
    @users = users
    @word = word
    @target = target
    @require_retire_user = require_retire_user
  end

  def search
    validated_search_word = validate_search_word

    searched_user = @users ? @users.merge(User.search_by_keywords(word: validated_search_word, exact_match: true)) : User.search_by_keywords(word: validated_search_word, exact_match: true)

    if @target == 'retired'
      searched_user.unscope(where: :retired_on).retired
    elsif @require_retire_user
      searched_user.unscope(where: :retired_on)
    else
      searched_user
    end
  end

  def validate_search_word
    stripped_word = @word.strip
    return nil if stripped_word.blank?

    if stripped_word.match?(/^[\w-]+$/)
      stripped_word if stripped_word.length >= 3
    elsif stripped_word.length >= 2
      stripped_word
    end
  end
end
