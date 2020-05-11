# frozen_string_literal: true

class Metric
  class << self
    def check_count(user_id)
      Check.where(
        user_id: user_id,
        created_at: 1.month.ago..Float::INFINITY
      ).count
    end

    def check(user_id)
      %w[Report Product].map do |type|
        data = Check.where(
          checkable_type: type,
          user_id: user_id,
          created_at: 1.month.ago..Float::INFINITY
        ).group_by_day(:created_at, format: "%m/%d").count
        { name: type.constantize.model_name.human, data: data }
      end
    end
  end
end
