# frozen_string_literal: true

module UnifiedSearch
  module SqlBlocks
    def products_block
      pract_title_expr = column_expr('practices', %w[title name])
      prod_title_expr  = column_expr('products',  %w[title name])

      coalesced_title = "COALESCE(#{pract_title_expr}, #{prod_title_expr})"

      body = column_expr('products', %w[body description])
      uid  = user_id_expr('products')

      <<~SQL
        SELECT products.id, 'products' AS record_type, #{coalesced_title} AS title, #{body} AS body,
               NULL::text AS description, #{uid} AS user_id, products.updated_at AS updated_at,
               FALSE AS wip, NULL::text AS commentable_type, NULL::bigint AS commentable_id
        FROM products LEFT JOIN practices ON practices.id = products.practice_id
        #{where_sql_for([coalesced_title, body], user_id_column: uid)}
      SQL
    end

    def select_block(table, title_cands, body_cands, user_id_sql: nil)
      title = column_expr(table, title_cands)
      body = column_expr(table, body_cands)
      user_id_sql ||= user_id_expr(table)
      wip = column_exists?(table, 'wip') ? "COALESCE(#{table}.wip, FALSE)" : 'FALSE'

      <<~SQL
        SELECT #{table}.id, '#{table}' AS record_type, #{title} AS title, #{body} AS body, NULL::text AS description,
               #{user_id_sql} AS user_id, #{table}.updated_at AS updated_at, #{wip} AS wip,
               NULL::text AS commentable_type, NULL::bigint AS commentable_id
        FROM #{table}
        #{where_sql_for([title, body], user_id_column: user_id_sql)}
      SQL
    end

    def questions_block
      q_title = column_expr('questions', UnifiedSearch::Builder::FALLBACK_TITLE_CANDIDATES)
      a_body = column_expr('answers', %w[description body])
      a_uid = user_id_expr('answers')
      kws = @words.reject { |w| w.start_with?('user:') }

      answers_sql = build_answers_query(q_title, a_body, a_uid, kws, false)
      correct_sql = build_answers_query(q_title, a_body, a_uid, kws, true)

      "#{answers_sql}\nUNION ALL\n#{correct_sql}"
    end

    private

    def build_answers_query(q_title, a_body, a_uid, keywords, is_correct)
      record_type = is_correct ? 'correct_answers' : 'answers'
      where_clause = build_answers_where_clause(a_body, keywords, is_correct)

      <<~SQL
        SELECT answers.id, '#{record_type}' AS record_type, #{q_title} AS title, #{a_body} AS body, NULL::text AS description,
               #{a_uid} AS user_id, answers.updated_at AS updated_at, FALSE AS wip, 'Question' AS commentable_type,
               answers.question_id AS commentable_id
        FROM answers JOIN questions ON questions.id = answers.question_id
        #{where_clause}
      SQL
    end

    def build_answers_where_clause(body_column, keywords, is_correct)
      conditions = [
        answer_type_condition(is_correct),
        *user_conditions,
        *keyword_filters(body_column, keywords)
      ].compact

      "WHERE #{conditions.join(' AND ')}"
    end

    def answer_type_condition(is_correct)
      is_correct ? "answers.type = 'CorrectAnswer'" : "(answers.type IS NULL OR answers.type != 'CorrectAnswer')"
    end

    def user_conditions
      user_words = @words.select { |w| w.start_with?('user:') }
      return nil if user_words.empty?

      user_ids = user_words.map { |w| User.find_by(login_name: w.delete_prefix('user:'))&.id }.compact
      if user_ids.any?
        "answers.user_id IN (#{user_ids.join(',')})"
      else
        '1=0'
      end
    end

    def keyword_filters(body_column, keywords)
      keywords.map { |w| "(#{body_column} ILIKE #{quote("%#{w}%")})" }
    end

    def comments_block
      basic = where_sql_for(['comments.description'], user_id_column: 'comments.user_id')
      conn = ActiveRecord::Base.connection
      comment_type = @document_type == :all ? nil : @document_type.to_s.camelize.singularize
      if comment_type && basic.present?
        quoted_type = conn.quote(comment_type)
        basic = "#{basic} AND comments.commentable_type = #{quoted_type}"
      elsif comment_type
        basic = "WHERE comments.commentable_type = #{conn.quote(comment_type)}"
      end

      exclude = "comments.commentable_type NOT IN ('Talk','Inquiry','CorporateTrainingInquiry')"
      combined = basic.blank? ? "WHERE #{exclude}" : "#{basic} AND #{exclude}"

      product_title_expr = column_expr('products', %w[title name])
      product_title = "COALESCE(#{product_title_expr}, '提出物')"

      <<~SQL
        SELECT comments.id, 'comments' AS record_type,
               CASE WHEN comments.commentable_type = 'Product' THEN #{product_title} ELSE NULL::text END AS title,
               comments.description AS body, NULL::text AS description, comments.user_id AS user_id,
               comments.updated_at AS updated_at, FALSE AS wip, comments.commentable_type, comments.commentable_id
        FROM comments LEFT JOIN products ON comments.commentable_type = 'Product' AND comments.commentable_id = products.id
        #{combined}
      SQL
    end

    def users_block
      users_desc = column_expr('users', ['description'])
      uid = 'users.id'
      <<~SQL
        SELECT users.id, 'users' AS record_type, users.login_name AS title, NULL::text AS body,
               #{users_desc} AS description, #{uid} AS user_id, users.updated_at AS updated_at,
               FALSE AS wip, NULL::text AS commentable_type, NULL::bigint AS commentable_id
        FROM users
        #{where_sql_for(['users.login_name', users_desc], user_id_column: uid)}
      SQL
    end
  end
end
