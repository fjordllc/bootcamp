# frozen_string_literal: true

class Searcher
  DOCUMENT_TYPES = [
    ["すべて", :all],
    ["お知らせ", :announcements],
    ["プラクティス", :practices],
    ["日報", :reports],
    ["Q&A", :questions],
    ["Docs", :pages]
  ]

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - [:all] + [:comments] + [:answers]

  def self.search(word, document_type: :all)
    if document_type == :all
      AVAILABLE_TYPES.flat_map { |type| result_for(type, word) }.sort_by { |result| result.created_at }.reverse
    elsif document_type.to_s.capitalize.singularize.constantize.include?(Commentable)
      [document_type, :comments].flat_map { |type| result_for(type, word, commentable_type: document_type.to_s.capitalize.singularize) }.sort_by { |result| result.created_at }.reverse
    elsif document_type == :questions
      [document_type, :answers].flat_map { |type| result_for(type, word) }
    else
      result_for(document_type, word).sort_by { |result| result.created_at }.reverse
    end
  end

  def self.result_for(type, word, commentable_type: nil)
    case type
    when :reports
      Report.ransack(groupings: word.split(/[[:blank:]]/).map { |w| { title_or_description_cont_all: w } }).result
    when :pages
      Page.ransack(groupings: word.split(/[[:blank:]]/).map { |w| { title_or_body_cont_all: w } }).result
    when :practices
      Practice.ransack(groupings: word.split(/[[:blank:]]/).map { |w| { title_or_description_or_goal_cont_all: w } }).result
    when :questions
      Question.ransack(groupings: word.split(/[[:blank:]]/).map { |w| { title_or_description_cont_all: w } }).result
    when :answers
      Answer.ransack(groupings: word.split(/[[:blank:]]/).map { |w| { description_cont_all: w } }).result
    when :announcements
      Announcement.ransack(groupings: word.split(/[[:blank:]]/).map { |w| { title_or_description_cont_all: w } }).result
    when :comments
      Comment.ransack(commentable_type_eq: commentable_type, groupings: word.split(/[[:blank:]]/).map { |w| { description_cont_all: w } }).result
    else
      []
    end
  end
end
