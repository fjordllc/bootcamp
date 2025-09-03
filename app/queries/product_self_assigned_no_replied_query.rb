# frozen_string_literal: true

class ProductSelfAssignedNoRepliedQuery < Patterns::Query
  queries Product

  private

  def initialize(relation = Product.all, user_id:)
    super(relation)
    @user_id = user_id
  end

  def query
    no_replied_product_ids = self_assigned_no_replied_product_ids
    relation
      .where(id: no_replied_product_ids)
      .order(published_at: :asc, id: :asc)
  end

  # rubocop:disable Metrics/MethodLength
  def self_assigned_no_replied_product_ids
    sql = <<~SQL
      WITH last_comments AS (
        SELECT *
        FROM comments AS parent
        WHERE commentable_type = 'Product' AND id = (
          SELECT id
          FROM comments AS child
          WHERE parent.commentable_id = child.commentable_id
            AND commentable_type = 'Product'
          ORDER BY created_at DESC LIMIT 1
        )
      ),
      self_assigned_products AS (
        SELECT products.*
        FROM products
        WHERE checker_id = ?
        AND wip = false
      )
      SELECT self_assigned_products.id
      FROM self_assigned_products
      LEFT JOIN last_comments ON self_assigned_products.id = last_comments.commentable_id
      WHERE last_comments.id IS NULL
      OR self_assigned_products.checker_id != last_comments.user_id
      ORDER BY self_assigned_products.created_at DESC
    SQL
    Product.find_by_sql([sql, @user_id]).map(&:id)
  end
  # rubocop:enable Metrics/MethodLength
end
