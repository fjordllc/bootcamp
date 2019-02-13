# frozen_string_literal: true

class Plan
  def self.standard_plan
    Stripe::Plan.list["data"].detect { |plan|  plan.nickname == "スタンダードプラン" }
  end
end
