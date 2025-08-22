# frozen_string_literal: true

class UncheckedNoRepliedProductsQuery < Patterns::Query
  queries Product

  private

  def query
    self_last_commented_products = relation
                                   .includes(:user, :comments)
                                   .where.not(commented_at: nil)
                                   .find_each.filter do |product|
      product.comments.last.user_id == product.user.id
    end

    no_comments_products = relation.where(commented_at: nil)

    no_replied_products_ids = (self_last_commented_products + no_comments_products).map(&:id)

    relation
      .unchecked
      .where(id: no_replied_products_ids)
      .order(published_at: :asc, id: :asc)
  end

  def initialize(relation = Product.all)
    super(relation)
  end
end
