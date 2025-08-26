# frozen_string_literal: true

module UnifiedSearch
  module SqlBlocks
    def products_block
      prod_title = column_expr('products', %w[title name])
      pract_title = column_expr('practices', %w[title name])
      coalesced = "COALESCE(NULLIF(#{prod_title}, ''), NULLIF(#{pract_title}, ''))"
      body = column_expr('products', %w[body description])
      uid = user_id_expr('products')

      <<~SQL
        SELECT products.id, 'products' AS record_type, #{coalesced} AS title, #{body} AS body,
               NULL::text AS description, #{uid} AS user_id, products.updated_at AS updated_at,
               FALSE AS wip, NULL::text AS commentable_type, NULL::bigint AS commentable_id
        FROM products LEFT JOIN practices ON practices.id = products.practice_id
        #{where_sql_for([coalesced, body], user_id_column: uid)}
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
      filters = kws.map { |w| "(#{a_body} ILIKE #{quote("%#{w}%")})" }.compact
      where_answers = filters.empty? ? 'WHERE FALSE' : "WHERE (answers.type IS NULL OR answers.type != 'CorrectAnswer') AND (#{filters.join(' AND ')})"

      answers_sql = <<~SQL
        SELECT answers.id, 'answers' AS record_type, #{q_title} AS title, #{a_body} AS body, NULL::text AS description,
               #{a_uid} AS user_id, answers.updated_at AS updated_at, FALSE AS wip, 'Question' AS commentable_type,
               answers.question_id AS commentable_id
        FROM answers JOIN questions ON questions.id = answers.question_id
        #{where_answers}
      SQL

      correct_body = column_expr('answers', %w[description body])
      correct_filters = kws.map { |w| "(#{correct_body} ILIKE #{quote("%#{w}%")})" }.compact
      where_correct = correct_filters.empty? ? 'WHERE FALSE' : "WHERE answers.type = 'CorrectAnswer' AND (#{correct_filters.join(' AND ')})"

      correct_sql = <<~SQL
        SELECT answers.id, 'correct_answers' AS record_type, #{q_title} AS title, #{correct_body} AS body, NULL::text AS description,
               #{a_uid} AS user_id, answers.updated_at AS updated_at, FALSE AS wip, 'Question' AS commentable_type,
               answers.question_id AS commentable_id
        FROM answers JOIN questions ON questions.id = answers.question_id
        #{where_correct}
      SQL

      "#{answers_sql}\nUNION ALL\n#{correct_sql}"
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

      product_title = "COALESCE(#{column_expr('products', %w[title name])}, '提出物')"

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
