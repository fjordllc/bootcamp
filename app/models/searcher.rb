# frozen_string_literal: true

class Searcher
  DOCUMENT_TYPES = [
    ['すべて', :all],
    ['お知らせ', :announcements],
    ['プラクティス', :practices],
    ['日報', :reports],
    ['提出物', :products],
    ['Q&A', :questions],
    ['Docs', :pages],
    ['イベント', :events],
    ['定期イベント', :regular_events],
    ['ユーザー', :users]
  ].freeze

  AVAILABLE_TYPES = DOCUMENT_TYPES.map(&:second) - %i[all] + %i[comments answers correct_answers]

  attr_reader :current_user, :word, :document_type, :only_me, :words

  def self.search(word:, current_user:, document_type: :all, only_me: false)
    new(
      word:,
      current_user:,
      document_type:,
      only_me:
    ).results
  end

  def initialize(current_user:, word:, document_type: :all, only_me: false)
    @current_user = current_user
    @word = word.to_s.strip
    @document_type = document_type.to_sym
    @only_me = only_me
    @words = @word.split(/[[:blank:]]+/).reject(&:blank?)
  end

  def results(*)
    if union_target?
      union_search
    else
      collection = Searcher::SearchableCollection.new(
        words:,
        document_type:,
        current_user:,
        only_me:
      )
      collection.results
    end
  end

  private

  def union_target?
    %i[
      announcements practices reports products questions answers
      pages events regular_events comments correct_answers
    ].include?(document_type) || document_type == :all
  end

  def union_search(*)
    query = UnifiedSearch::Query.new(
      words:,
      document_type:,
      only_me:,
      current_user_id: current_user.id
    )

    rows, = execute_union_query(query)
    stubs = rows.map { |r| Searcher::SearchRow.new(r) }
    users_by_id = preload_users_for(stubs)

    stubs.map do |stub|
      SearchResult.new(stub, word, current_user, users_by_id:)
    end
  end

  def execute_union_query(query)
    conn = ActiveRecord::Base.connection
    page_limit = ENV.fetch('SEARCH_MAX_ROWS', '500').to_i.clamp(1, 10_000)
    rows = conn.exec_query(query.page_sql(limit: page_limit, offset: 0)).to_a
    total_count = conn.select_value(query.count_sql).to_i
    [rows, total_count]
  end

  def preload_users_for(searchables)
    ids = searchables.map(&:user_id).compact.uniq
    return {} if ids.empty?

    User.with_attached_avatar.where(id: ids).index_by(&:id)
  end
end
