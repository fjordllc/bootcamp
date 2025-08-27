# frozen_string_literal: true

require Rails.root.join('app/queries/unified_search/query').to_s
require_relative 'search_methods_fetching'

module Searcher::SearchMethods
  def search(word:, current_user:, **options)
    only_me = options.fetch(:only_me, false)
    document_type = options.fetch(:document_type, :all)
    page = options.fetch(:page, nil)
    all = options.fetch(:all, false)

    words = word.split(/[[:blank:]]+/).reject(&:blank?)

    return union_search(words:, current_user:, only_me:, document_type:, page:, all:) if document_type == :all || union_target?(document_type)

    searchables = fetch_results(words, document_type).select { |s| visible_to_user?(s, current_user) }
    users_by_id = preload_users_for(searchables)

    delete_private_comment!(searchables).map { |s| SearchResult.new(s, word, current_user, users_by_id:) }
  end

  def union_target?(type)
    %i[
      announcements practices reports products questions answers
      pages events regular_events comments
    ].include?(type)
  end

  def union_search(words:, current_user:, **options)
    only_me = options.fetch(:only_me, false)
    document_type = options.fetch(:document_type, :all)
    page = options.fetch(:page, nil)
    all = options.fetch(:all, false)

    current_page, per_page, offset = compute_pagination(page, all)

    q = UnifiedSearch::Query.new(
      words:,
      document_type:,
      only_me:,
      current_user_id: current_user.id
    )

    rows, total = execute_union_query(q, per_page, offset)

    stubs = rows.map { |r| Searcher::SearchRow.new(r) }
    users_by_id = preload_users_for(stubs)

    results = stubs.map do |stub|
      SearchResult.new(stub, words.join(' '), current_user, users_by_id:)
    end

    Kaminari.paginate_array(results, total_count: total).page(current_page).per(per_page)
  end

  def compute_pagination(page, all)
    current_page = (page.presence || 1).to_i
    per_page = if all
                 10_000
               else
                 begin
                   SearchablesController::PER_PAGE
                 rescue StandardError
                   Kaminari.config.default_per_page || 50
                 end
               end
    offset = (current_page - 1).clamp(0, 10_000) * per_page
    [current_page, per_page, offset]
  end

  def execute_union_query(query, per_page, offset)
    conn = ActiveRecord::Base.connection
    rows = conn.exec_query(query.page_sql(limit: per_page, offset:)).to_a
    total = conn.select_value(query.count_sql).to_i
    [rows, total]
  end

  private :union_target?, :union_search, :compute_pagination, :execute_union_query

  include SearchMethodsFetching::Fetching
end
