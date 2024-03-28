# frozen_string_literal: true

module SearchUser
  def validate_search_word(search_word)
    if search_word.match?(/^[\w-]+$/)
      search_word.strip if search_word.strip.length >= 3
    elsif search_word.strip.length >= 2
      search_word.strip
    end
  end
end
