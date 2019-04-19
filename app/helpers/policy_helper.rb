# frozen_string_literal: true

module PolicyHelper
  def policy(record)
    "#{record.class}Policy".constantize.new(current_user, record)
  end
end
