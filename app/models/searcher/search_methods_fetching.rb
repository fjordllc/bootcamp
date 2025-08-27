# frozen_string_literal: true

module Searcher::SearchMethods
  module Fetching
    private

    def fetch_results(words, document_type)
      return results_for_all(words) if document_type == :all

      model(document_type)
      return result_for_questions(document_type, words) if document_type == :questions

      base_rel = result_for(document_type, words)
      comments_rel = result_for(:comments, words)
      comments_rel = comments_rel.where(commentable_type: search_model_name(document_type)) if document_type != :all

      metas = merge_metas_for(base_rel, comments_rel, document_type)
      load_records_from_metas(metas)
    end

    def results_for_all(words)
      if (user_filter = extract_user_filter(words))
        content_words = words.reject { |w| w.start_with?('user:') }
        return search_by_user_filter(user_filter, content_words)
      end

      metas = collect_metas_for_all_types(words)
      sorted = sorted_unique_metas(metas)
      load_records_from_metas(sorted)
    end

    def collect_metas_for_all_types(words)
      metas = []

      AVAILABLE_TYPES.each do |type|
        rel = result_for(type, words)
        next unless rel

        metas.concat(rel.pluck(:id, :updated_at).map { |id, ua| { type:, id:, updated_at: ua } })
      end

      metas.concat(search_users(words).pluck(:id, :updated_at).map { |id, ua| { type: :users, id:, updated_at: ua } })
      metas
    end

    def sorted_unique_metas(metas)
      metas.uniq { |m| [m[:type], m[:id]] }
           .sort_by { |m| m[:updated_at] || Time.zone.at(0) }
           .reverse
    end

    def merge_metas_for(base_rel, comments_rel, document_type)
      base_meta = base_rel.pluck(:id, :updated_at).map { |id, ua| { type: document_type, id:, updated_at: ua } }
      comment_meta = comments_rel.pluck(:id, :updated_at).map { |id, ua| { type: :comments, id:, updated_at: ua } }

      (base_meta + comment_meta).uniq { |m| [m[:type], m[:id]] }.sort_by { |m| m[:updated_at] || Time.zone.at(0) }.reverse
    end

    def load_records_from_metas(metas)
      return [] if metas.empty?

      grouped = metas.group_by { |m| m[:type] }
      records_map = {}

      grouped.each do |type, entries|
        ids = entries.map { |e| e[:id] }.uniq
        klass = type == :comments ? Comment : model(type)
        next unless klass

        records_map[type] = klass.where(id: ids).index_by(&:id)
      end

      metas.map do |m|
        records_map.dig(m[:type], m[:id])
      end.compact
    end
  end

  include Fetching
end
