# frozen_string_literal: true

class Searcher::SearchRow
  attr_reader :id, :record_type, :title, :body, :description, :user_id,
              :updated_at, :wip, :commentable_type, :commentable_id

  LABEL_MAP = {
    'regular_events' => "定期\nイベント",
    'events' => "特別\nイベント",
    'practices' => "プラク\nティス",
    'answers' => 'Q&A',
    'correct_answers' => 'Q&A',
    'comments' => 'コメント'
  }.freeze

  COMMENTABLE_LABEL_MAP = {
    'Announcement' => 'お知らせ',
    'Practice' => "プラク\nティス",
    'Report' => '日報',
    'Product' => '提出物',
    'Question' => 'Q&A',
    'Page' => 'Docs',
    'Event' => "特別\nイベント",
    'RegularEvent' => "定期\nイベント"
  }.freeze

  def initialize(attrs)
    @id = attrs['id']
    @record_type = attrs['record_type']
    @title = attrs['title']
    @body  = attrs['body']
    @description = attrs['description']
    @user_id = attrs['user_id']
    @updated_at = attrs['updated_at'].is_a?(String) ? Time.zone.parse(attrs['updated_at']) : attrs['updated_at']
    @wip = attrs['wip']
    @commentable_type = attrs['commentable_type']
    @commentable_id   = attrs['commentable_id']
  end

  def class
    OpenStruct.new(name: record_type.classify)
  end

  def try(sym)
    send(sym) if respond_to?(sym)
  end

  def model_name
    OpenStruct.new(name: record_type.classify)
  end

  def label
    LABEL_MAP.fetch(record_type, I18n.t("activerecord.models.#{record_type.singularize}", default: record_type))
  end

  def comment_label
    return 'コメント' if commentable_type.blank?

    COMMENTABLE_LABEL_MAP.fetch(commentable_type, 'コメント')
  end

  def formatted_updated_at
    weekdays = %w[日 月 火 水 木 金 土]
    updated_at.strftime("%Y年%m月%d日(#{weekdays[updated_at.wday]}) %H:%M")
  end

  def commentable
    return nil unless commentable_type.present? && commentable_id.present?

    klass = commentable_type.safe_constantize
    return nil unless klass

    case klass.name
    when 'Product'
      Product.where(id: commentable_id).preload(:practice).first
    else
      klass.find_by(id: commentable_id)
    end
  rescue StandardError
    nil
  end
end
