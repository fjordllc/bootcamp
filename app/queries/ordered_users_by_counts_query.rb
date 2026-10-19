# frozen_string_literal: true

class OrderedUsersByCountsQuery < Patterns::Query
  queries User

  private

  def initialize(relation = User.all, order_by:, direction:)
    super(relation)
    @order_by = order_by
    @direction = direction
  end

  def query
    raise ArgumentError, 'Invalid argument' unless valid_column?(@order_by) && valid_column?(@direction)

    if @order_by.in? %w[report comment]
      relation
        .left_outer_joins(@order_by.pluralize.to_sym)
        .group('users.id')
        .order(Arel.sql("count(#{@order_by.pluralize}.id) #{@direction}, users.created_at"))
    elsif @order_by == 'created_at'
      relation.order(@order_by.to_sym => @direction.to_sym)
    else
      relation.order(@order_by.to_sym => @direction.to_sym, created_at: :asc)
    end
  end

  def valid_column?(value)
    value.in?(User::VALID_SORT_COLUMNS)
  end
end
