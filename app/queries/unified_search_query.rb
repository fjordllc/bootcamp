# frozen_string_literal: true

class UnifiedSearchQuery
  COLUMNS_SQL = <<~SQL
    id, record_type, title, body, description, user_id, updated_at, wip, commentable_type, commentable_id
  SQL

  FALLBACK_TITLE_CANDIDATES = %w[title name login_name].freeze
  FALLBACK_BODY_CANDIDATES  = %w[body description].freeze

  def initialize(words:, document_type:, only_me:, current_user_id:)
    @words          = Array(words)
    @document_type  = document_type
    @only_me        = only_me
    @current_user_id = current_user_id
    @column_expr_cache = {}
  end

  def page_sql(limit:, offset:)
    <<~SQL
      #{wrapped_union_sql}
      ORDER BY updated_at DESC
      LIMIT #{Integer(limit)} OFFSET #{Integer(offset)}
    SQL
  end

  def count_sql
    <<~SQL
      SELECT COUNT(*) FROM (#{union_sql}) AS unified
    SQL
  end

  private

  def union_sql
    selects = []
    enabled = target_types

    if enabled.include?(:announcements)
      selects << select_block(
        table: 'announcements',
        title_candidates: FALLBACK_TITLE_CANDIDATES,
        body_candidates: FALLBACK_BODY_CANDIDATES
      )
    end

    if enabled.include?(:practices)
      selects << select_block(
        table: 'practices',
        title_candidates: FALLBACK_TITLE_CANDIDATES,
        body_candidates: %w[description body],
        user_id_sql: resolve_user_id_expr('practices', prefer_last_updated: true)
      )
    end

    if enabled.include?(:reports)
      selects << select_block(
        table: 'reports',
        title_candidates: FALLBACK_TITLE_CANDIDATES,
        body_candidates: %w[description body]
      )
    end

    if enabled.include?(:products)
      products_title_expr  = resolve_column_expr('products', %w[title name])
      practices_title_expr = resolve_column_expr('practices', %w[title name])
      coalesced_title_expr =
        "COALESCE(NULLIF(#{products_title_expr}, ''), NULLIF(#{practices_title_expr}, ''))"

      body_expr    = resolve_column_expr('products', FALLBACK_BODY_CANDIDATES)
      user_id_expr = resolve_user_id_expr('products', prefer_last_updated: false)

      selects << <<~SQL
        SELECT
          products.id,
          'products' AS record_type,
          #{coalesced_title_expr} AS title,
          #{body_expr} AS body,
          NULL::text AS description,
          #{user_id_expr} AS user_id,
          products.updated_at AS updated_at,
          FALSE AS wip,
          NULL::text AS commentable_type,
          NULL::bigint AS commentable_id
        FROM products
        LEFT JOIN practices ON practices.id = products.practice_id
        #{where_sql_for([coalesced_title_expr, body_expr], table_alias: nil, user_id_column: user_id_expr)}
      SQL
    end

    if enabled.include?(:questions)
      questions_title_expr = resolve_column_expr('questions', FALLBACK_TITLE_CANDIDATES)
      resolve_column_expr('questions', ['description'])
      answers_body_expr = resolve_column_expr('answers', ['body'])
      resolve_user_id_expr('answers', prefer_last_updated: false)
      resolve_column_expr('answers', ['body'])
      resolve_user_id_expr('answers', prefer_last_updated: false)

      selects << select_block(
        table: 'questions',
        title_candidates: FALLBACK_TITLE_CANDIDATES,
        body_candidates: FALLBACK_BODY_CANDIDATES
      )

      base_where_cond = "answers.type IS NULL OR answers.type != 'CorrectAnswer'"

      answers_body_expr = resolve_column_expr('answers', %w[description body])
      answers_user_id_expr = resolve_user_id_expr('answers', prefer_last_updated: false)

      keyword_words = @words.reject { |w| w.start_with?('user:') }

      answers_keyword_filters = keyword_words.map do |w|
        next nil if /\ANULL::/i.match?(answers_body_expr)

        esc = ActiveRecord::Base.connection.quote("%#{w}%")
        "(#{answers_body_expr} ILIKE #{esc})"
      end.compact

      combined_where_for_answers =
        if answers_keyword_filters.empty?
          'WHERE FALSE'
        else
          "WHERE (#{base_where_cond}) AND (#{answers_keyword_filters.join(' AND ')})"
        end

      selects << <<~SQL
        SELECT
          answers.id,
          'answers' AS record_type,
          #{questions_title_expr} AS title,
          #{answers_body_expr} AS body,
          NULL::text AS description,
          #{answers_user_id_expr} AS user_id,
          answers.updated_at AS updated_at,
          FALSE AS wip,
          'Question' AS commentable_type,
          answers.question_id AS commentable_id
        FROM answers
        JOIN questions ON questions.id = answers.question_id
        #{combined_where_for_answers}
      SQL

      correct_body_expr = resolve_column_expr('answers', %w[description body])
      correct_answers_user_id_expr = answers_user_id_expr

      correct_keyword_filters = keyword_words.map do |w|
        next nil if /\ANULL::/i.match?(correct_body_expr)

        esc = ActiveRecord::Base.connection.quote("%#{w}%")
        "(#{correct_body_expr} ILIKE #{esc})"
      end.compact

      combined_correct_where =
        if correct_keyword_filters.empty?
          'WHERE FALSE'
        else
          "WHERE answers.type = 'CorrectAnswer' AND (#{correct_keyword_filters.join(' AND ')})"
        end

      selects << <<~SQL
        SELECT
          answers.id,
          'correct_answers' AS record_type,
          #{questions_title_expr} AS title,
          #{correct_body_expr} AS body,
          NULL::text AS description,
          #{correct_answers_user_id_expr} AS user_id,
          answers.updated_at AS updated_at,
          FALSE AS wip,
          'Question' AS commentable_type,
          answers.question_id AS commentable_id
        FROM answers
        JOIN questions ON questions.id = answers.question_id
        #{combined_correct_where}
      SQL

    end

    if enabled.include?(:pages)
      selects << select_block(
        table: 'pages',
        title_candidates: FALLBACK_TITLE_CANDIDATES,
        body_candidates: FALLBACK_BODY_CANDIDATES
      )
    end

    if enabled.include?(:events)
      selects << select_block(
        table: 'events',
        title_candidates: FALLBACK_TITLE_CANDIDATES,
        body_candidates: FALLBACK_BODY_CANDIDATES
      )
    end

    if enabled.include?(:regular_events)
      selects << select_block(
        table: 'regular_events',
        title_candidates: FALLBACK_TITLE_CANDIDATES,
        body_candidates: FALLBACK_BODY_CANDIDATES
      )
    end

    if enabled.include?(:comments) || @document_type != :all
      conn = ActiveRecord::Base.connection
      commentable_type_name = @document_type == :all ? nil : @document_type.to_s.camelize.singularize
      basic_where = where_sql_for(['comments.description'], table_alias: nil, user_id_column: 'comments.user_id')

      if commentable_type_name.present?
        quoted_type = conn.quote(commentable_type_name)
        combined_where = basic_where.blank? ? "WHERE comments.commentable_type = #{quoted_type}" : "#{basic_where} AND comments.commentable_type = #{quoted_type}"
      else
        combined_where = basic_where
      end

      exclude_talk_clause = "comments.commentable_type NOT IN ('Talk','Inquiry','CorporateTrainingInquiry')"
      combined_where = if combined_where.blank?
                         "WHERE #{exclude_talk_clause}"
                       else
                         "#{combined_where} AND #{exclude_talk_clause}"
                       end

      product_title_col = resolve_column_expr('products', %w[title name])
      product_title_expr = "COALESCE(#{product_title_col}, '提出物')"

      selects << <<~SQL
        SELECT
          comments.id,
          'comments' AS record_type,
          CASE WHEN comments.commentable_type = 'Product' THEN #{product_title_expr} ELSE NULL::text END AS title,
          comments.description AS body,
          NULL::text AS description,
          comments.user_id AS user_id,
          comments.updated_at AS updated_at,
          FALSE AS wip,
          comments.commentable_type,
          comments.commentable_id
        FROM comments
        LEFT JOIN products ON comments.commentable_type = 'Product' AND comments.commentable_id = products.id
        #{combined_where}
      SQL
    end

    if enabled.include?(:users)
      users_title_expr = 'users.login_name'
      users_body_expr  = 'NULL::text'
      users_description_expr = resolve_column_expr('users', ['description'])
      users_user_id_expr = 'users.id'

      selects << <<~SQL
        SELECT
          users.id,
          'users' AS record_type,
          #{users_title_expr} AS title,
          #{users_body_expr} AS body,
          #{users_description_expr} AS description,
          #{users_user_id_expr} AS user_id,
          users.updated_at AS updated_at,
          FALSE AS wip,
          NULL::text AS commentable_type,
          NULL::bigint AS commentable_id
        FROM users
        #{where_sql_for([users_title_expr, users_description_expr], table_alias: nil, user_id_column: users_user_id_expr)}
      SQL
    end

    selects.join("\nUNION ALL\n")
  end

  def wrapped_union_sql
    "SELECT #{COLUMNS_SQL} FROM (#{union_sql}) AS unified"
  end

  def resolve_user_id_expr(table, prefer_last_updated: false)
    cache_key = "user_id:#{table}:#{prefer_last_updated}"
    return @column_expr_cache[cache_key] if @column_expr_cache.key?(cache_key)

    conn = ActiveRecord::Base.connection
    has_user_id = conn.column_exists?(table, 'user_id')
    has_last_updated = conn.column_exists?(table, 'last_updated_user_id')

    expr =
      if prefer_last_updated && has_last_updated && has_user_id
        "COALESCE(#{table}.last_updated_user_id, #{table}.user_id)"
      elsif has_last_updated && !has_user_id
        "#{table}.last_updated_user_id"
      elsif has_user_id
        "#{table}.user_id"
      else
        'NULL::bigint'
      end

    @column_expr_cache[cache_key] = expr
  end

  def resolve_column_expr(table, candidates)
    cache_key = "col_expr:#{table}:#{Array(candidates).join(',')}"
    return @column_expr_cache[cache_key] if @column_expr_cache.key?(cache_key)

    conn = ActiveRecord::Base.connection
    resolved_col = Array(candidates).find { |col| conn.column_exists?(table, col) }

    expr = if resolved_col
             "#{table}.#{resolved_col}"
           else
             'NULL::text'
           end

    @column_expr_cache[cache_key] = expr
  end

  def select_block(table:, title_candidates:, body_candidates:, user_id_sql: nil)
    conn = ActiveRecord::Base.connection

    title_expr = resolve_column_expr(table, title_candidates)
    body_expr  = resolve_column_expr(table, body_candidates)
    user_id_sql ||= resolve_user_id_expr(table, prefer_last_updated: false)

    wip_expr =
      if conn.column_exists?(table, 'wip')
        "COALESCE(#{table}.wip, FALSE)"
      else
        'FALSE'
      end

    <<~SQL
      SELECT
        #{table}.id,
        '#{table}' AS record_type,
        #{title_expr} AS title,
        #{body_expr}  AS body,
        NULL::text AS description,
        #{user_id_sql} AS user_id,
        #{table}.updated_at AS updated_at,
        #{wip_expr} AS wip,
        NULL::text AS commentable_type,
        NULL::bigint AS commentable_id
      FROM #{table}
      #{where_sql_for([title_expr, body_expr], table_alias: table, user_id_column: user_id_sql)}
    SQL
  end

  def where_sql_for(columns, table_alias:, user_id_column:)
    filters = []
    conn = ActiveRecord::Base.connection

    filters << "#{user_id_column} = #{@current_user_id}" if @only_me

    user_words, keyword_words = @words.partition { |w| w.start_with?('user:') }
    if user_words.any?
      logins = user_words.map { |w| conn.quote(w.delete_prefix('user:')) }
      filters << "#{user_id_column} IN (SELECT id FROM users WHERE login_name IN (#{logins.join(', ')}))"
    end

    keyword_words.each do |w|
      esc = conn.quote("%#{w}%")
      searchable_cols = columns.reject { |c| c =~ /\ANULL::/i }
      next if searchable_cols.empty?

      filters << '(' + searchable_cols.map { |c| "#{c} ILIKE #{esc}" }.join(' OR ') + ')'
    end

    filters.empty? ? '' : "WHERE #{filters.join(' AND ')}"
  end

  def target_types
    return Searcher::AVAILABLE_TYPES if @document_type == :all

    [@document_type]
  end
end
