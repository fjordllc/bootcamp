# frozen_string_literal: true

module UnifiedSearch
  module Exprs
    def with_conn(&block)
      ActiveRecord::Base.connection_pool.with_connection(&block)
    end

    def where_sql_for(columns, user_id_column:)
      filters = []
      filters << "#{user_id_column} = #{@current_user_id}" if @only_me

      user_words, = @words.partition { |w| w.start_with?('user:') }
      user_filter = build_user_filter(user_words, user_id_column)
      filters << user_filter if user_filter.present?

      keyword_filters = build_keyword_filters(columns)
      filters.concat(keyword_filters) if keyword_filters.any?

      filters.empty? ? '' : "WHERE #{filters.join(' AND ')}"
    end

    def build_user_filter(user_words, user_id_column)
      return nil if user_words.empty?

      logins = user_words.map { |w| quote(w.delete_prefix('user:')) }
      "#{user_id_column} IN (SELECT id FROM users WHERE login_name IN (#{logins.join(', ')}))"
    end

    def build_keyword_filters(columns)
      keywords = @words.reject { |w| w.start_with?('user:') }
      filters = []
      keywords.each do |w|
        esc = quote("%#{w}%")
        cols = columns.reject { |c| c =~ /\ANULL::/i }
        next if cols.empty?

        filters << "(#{cols.map { |col| "#{col} ILIKE #{esc}" }.join(' OR ')})"
      end
      filters
    end

    def user_id_expr(table, prefer_last_updated: false)
      cache_key = "uid:#{table}:#{prefer_last_updated}"
      return @cache[cache_key] if @cache.key?(cache_key)

      expr = compute_user_id_expr(table, prefer_last_updated)
      @cache[cache_key] = expr
    end

    def compute_user_id_expr(table, prefer_last_updated)
      with_conn do |conn|
        has_uid = conn.column_exists?(table, 'user_id')
        has_last = conn.column_exists?(table, 'last_updated_user_id')

        if prefer_last_updated && has_last && has_uid
          "COALESCE(#{table}.last_updated_user_id, #{table}.user_id)"
        elsif has_last && !has_uid
          "#{table}.last_updated_user_id"
        elsif has_uid
          "#{table}.user_id"
        else
          'NULL::bigint'
        end
      end
    end

    def column_expr(table, candidates)
      cache_key = "col:#{table}:#{Array(candidates).join(',')}"
      return @cache[cache_key] if @cache.key?(cache_key)

      expr = with_conn do |conn|
        found = Array(candidates).find { |c| conn.column_exists?(table, c) }
        found ? "#{table}.#{found}" : 'NULL::text'
      end

      @cache[cache_key] = expr
    end

    def column_exists?(table, col)
      with_conn { |conn| conn.column_exists?(table, col) }
    end

    def quote(val)
      with_conn { |conn| conn.quote(val) }
    end
  end
end
