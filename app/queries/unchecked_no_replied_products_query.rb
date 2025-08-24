# frozen_string_literal: true

class UncheckedNoRepliedProductsQuery < Patterns::Query
  queries Product

  private

  def query
    last_comment_join_sql = <<~SQL.squish
      LEFT JOIN comments AS last_comments
        ON last_comments.id = (
          SELECT cs.id
          FROM comments cs
          WHERE cs.commentable_type = 'Product'
            AND cs.commentable_id = products.id
          ORDER BY cs.created_at DESC, cs.id DESC
          LIMIT 1
        )
    SQL

    relation
      .unchecked
      .joins(last_comment_join_sql)
      .where('last_comments.id IS NULL OR last_comments.user_id = products.user_id')
  end

  def initialize(relation = Product.all)
    super(relation)
  end
end
