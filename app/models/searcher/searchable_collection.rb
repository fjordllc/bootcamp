# frozen_string_literal: true

class Searcher::SearchableCollection
  attr_reader :words, :document_type, :current_user

  META_SORT_KEY = ->(m) { m[:updated_at] || Time.zone.at(0) }.freeze

  def initialize(words:, current_user:, document_type: :all)
    @words = Array(words).flat_map { |w| w.to_s.split(/[[:blank:]]+/) }.reject(&:blank?)
    @document_type = document_type.to_sym
    @current_user = current_user
  end

  def results(*)
    rows = union_target? ? union_search : fetch_and_filter
    rows.map { |r| SearchResult.new(r, words.join(' '), current_user) }
  end

  private

  def union_target?
    %i[announcements practices reports products questions answers pages events regular_events comments].include?(document_type) || document_type == :all
  end

  def union_search(*)
    Searcher.new(current_user:, word: words.join(' '), document_type:).results
  end

  def fetch_and_filter
    metas = document_type == :all ? collect_all_metas : fetch_metas_for(document_type)
    records = load_records_from_metas(metas).select { |r| visible_to_user?(r) }
    records.select! { |r| r.respond_to?(:user_id) && r.user_id == current_user.id } if @only_me
    records
  end

  def fetch_metas_for(type)
    type == :users ? user_metas : type_metas(type)
  end

  def collect_all_metas
    (non_user_metas + user_metas).uniq { |m| [m[:type], m[:id]] }.sort_by(&META_SORT_KEY).reverse
  end

  def non_user_metas
    Searcher::AVAILABLE_TYPES.reject { |t| t == :users }.flat_map do |type|
      rel = result_for(type, words)
      next [] unless rel

      rel.pluck(:id, :updated_at).map { |id, ua| { type:, id:, updated_at: ua } }
    end
  end

  def user_metas
    search_users(words).map { |u| { type: :users, id: u.id, updated_at: u.updated_at || Time.current } }
  end

  def type_metas(type)
    base_rel = result_for(type, words)
    comment_rel = result_for(:comments, words)
    comment_rel = comment_rel.where(commentable_type: search_model_name(type)) if type != :all
    merge_metas(base_rel, comment_rel, type)
  end

  def merge_metas(base, comments, type)
    base_meta = base.pluck(:id, :updated_at).map { |id, ua| { type:, id:, updated_at: ua } }
    comment_meta = comments.pluck(:id, :updated_at).map { |id, ua| { type: :comments, id:, updated_at: ua } }
    (base_meta + comment_meta).uniq { |m| [m[:type], m[:id]] }.sort_by(&META_SORT_KEY).reverse
  end

  def load_records_from_metas(metas)
    return [] if metas.empty?

    grouped = metas.group_by { |m| m[:type] }.transform_values { |entries| records_by_type(entries) }
    metas.map { |m| grouped.dig(m[:type], m[:id]) }.compact
  end

  def records_by_type(entries)
    ids = entries.map { |e| e[:id] }.uniq
    case entries.first[:type]
    when :comments then Comment.where(id: ids).index_by(&:id)
    when :users then User.where(id: ids).index_by(&:id)
    else model(entries.first[:type])&.where(id: ids)&.index_by(&:id)
    end
  end

  def visible_to_user?(record)
    case record
    when User, Practice, Page, Event, RegularEvent, Announcement, Report, Product, Question, Answer
      true
    when Talk then current_user.admin? || record.user_id == current_user.id
    when Comment
      record.commentable.is_a?(Talk) ? (current_user.admin? || record.commentable.user_id == current_user.id) : true
    else false
    end
  end

  def model(type)
    search_model_name(type)&.constantize
  end

  def search_model_name(type)
    {
      announcements: 'Announcement',
      practices: 'Practice',
      reports: 'Report',
      products: 'Product',
      questions: 'Question',
      answers: 'Answer',
      pages: 'Page',
      events: 'Event',
      regular_events: 'RegularEvent',
      comments: 'Comment',
      users: 'User'
    }[type]
  end

  def search_users(words)
    return User.all if words.blank?

    User.where(
      words.map { '(login_name ILIKE ? OR name ILIKE ? OR description ILIKE ?)' }.join(' AND '),
      *words.flat_map { |w| ["%#{w}%", "%#{w}%", "%#{w}%"] }
    )
  end
end
