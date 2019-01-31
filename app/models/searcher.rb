# frozen_string_literal: true

class Searcher
  FILTERS = [
    ['すべて', :all],
    ['お知らせ', :announcements],
    ['プラクティス', :practices],
    ['日報', :reports],
    ['Q&A', :questions],
    ['Wiki', :pages]
  ]

  AVAILABLE_TYPES = FILTERS.map(&:second) - [:all]

  def self.search(word, filter: :all)
    if filter == :all
      AVAILABLE_TYPES.flat_map { |type| result_for(type, word) }
    else
      result_for(filter, word)
    end
  end

  def self.result_for(type, word)
    case type
    when :reports
      Report.ransack(title_or_description_cont_all: word).result
    when :pages
      Page.ransack(title_or_body_cont_all: word).result
    when :practices
      Practice.ransack(title_or_description_or_goal_cont_all: word).result
    when :questions
      Question.ransack(title_or_description_cont_all: word).result
    when :announcements
      Announcement.ransack(title_or_description_cont_all: word).result
    else
      []
    end
  end
end
