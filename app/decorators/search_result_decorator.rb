# frozen_string_literal: true

module SearchResultDecorator
  include ActionView::Helpers::SanitizeHelper
  include ERB::Util
  include MarkdownHelper
  include PolicyHelper

  EXTRACTING_CHARACTERS = 50

  def formatted_summary
    result = highlight_word(summary, keyword)
    result || ''
  end

  def formatted_updated_at
    weekdays = %w[日 月 火 水 木 金 土]
    resource.updated_at.strftime("%Y年%m月%d日(#{weekdays[resource.updated_at.wday]}) %H:%M")
  end

  def rendered_title
    return resource.question&.title if resource.is_a?(Answer) || resource.is_a?(CorrectAnswer)
    return resource.login_name if resource.is_a?(User)

    resource.try(:title) || ''
  end

  def type_label
    return resource.avatar_url if resource.is_a?(User)

    # Searcher設定から取得、なければresource_labelを使用
    config = Searcher::SEARCH_CONFIGS.find { |_, v| v[:model] == resource.class }&.last
    config&.dig(:label) || resource_label
  end

  def commentable_type_name
    return '' unless resource.try(:commentable)

    model_name = resource.commentable.model_name.name.underscore
    I18n.t("activerecord.models.#{model_name}", default: '')
  rescue StandardError => e
    Rails.logger.warn "Failed to fetch commentable type: #{e.message}"
    ''
  end

  def comment_label
    return 'コメント' unless resource.respond_to?(:commentable) && resource.commentable.present?

    case resource.commentable_type
    when 'Announcement' then 'お知らせ'
    when 'Practice' then "プラク\nティス"
    when 'Report' then '日報'
    when 'Product' then '提出物'
    when 'Question' then 'Q&A'
    when 'Page' then 'Docs'
    when 'Event' then "特別\nイベント"
    when 'RegularEvent' then "定期\nイベント"
    else 'コメント'
    end
  end

  def resource_label
    return resource.avatar_url if resource.model_name.name.casecmp?('User')

    case resource.model_name.name.downcase
    when 'regularevent' then "定期\nイベント"
    when 'event' then "特別\nイベント"
    when 'practice' then "プラク\nティス"
    when 'correctanswer', 'answer' then 'Q&A'
    when 'comment' then comment_label
    else
      I18n.t("activerecord.models.#{resource.model_name.name.underscore}")
    end
  end

  def url
    case resource
    when Comment
      "#{Rails.application.routes.url_helpers.polymorphic_path(resource.commentable)}#comment_#{resource.id}"
    when CorrectAnswer, Answer
      Rails.application.routes.url_helpers.question_path(resource.question, anchor: "answer_#{resource.id}")
    else
      helper_method = "#{resource.class.name.underscore}_path"
      Rails.application.routes.url_helpers.send(helper_method, resource)
    end
  end

  def filtered_content
    if resource.is_a?(Comment) && resource.commentable_type == 'Product'
      commentable = resource.commentable
      return '該当プラクティスを修了するまで他の人の提出物へのコメントは見れません。' unless policy(commentable).show? || commentable.practice.open_product?

      return resource.description
    end

    resource.try(:description) || resource.try(:body) || ''
  end

  def created_user
    resource.respond_to?(:user) ? resource.user : nil
  end

  private

  def highlight_word(text, word)
    return text unless text&.present? && word.present?

    escaped_text = ERB::Util.html_escape(text)
    words = word.split(/[[:blank:]]+/).reject(&:blank?)
    highlighted_text = words.reduce(escaped_text) do |text_fragment, w|
      text_fragment.gsub(/(#{Regexp.escape(w)})/i, '<strong class="matched_word">\1</strong>')
    end

    ActionController::Base.helpers.sanitize(highlighted_text, tags: %w[strong], attributes: %w[class])
  end

  def process_special_case(comment, word)
    # Handle special formatting cases (e.g., tables)
    # This would be the same logic as in the original SearchHelper
    summary = md2plain_text(comment)
    find_match_in_text(summary, word)
  end

  def find_match_in_text(text, word)
    return text[0, EXTRACTING_CHARACTERS * 2] if word.blank?

    words = word.split(/[[:blank:]]+/).reject(&:blank?)
    first_match_position = nil

    words.each do |w|
      position = text.downcase.index(w.downcase)
      first_match_position = position if position && (first_match_position.nil? || position < first_match_position)
    end

    if first_match_position
      start_pos = [0, first_match_position - EXTRACTING_CHARACTERS].max
      end_pos = [text.length, first_match_position + EXTRACTING_CHARACTERS].min
      text[start_pos...end_pos].strip
    else
      text[0, EXTRACTING_CHARACTERS * 2]
    end
  end
end
