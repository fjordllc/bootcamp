# frozen_string_literal: true

class JobSeekingUserCounts
  attr_reader :reports, :products, :works

  def initialize(user_ids)
    @reports = Report.where(user_id: user_ids).group(:user_id).count
    @products = Product.where(user_id: user_ids).group(:user_id).count
    @works = Work.where(user_id: user_ids).group(:user_id).count
    [@reports, @products, @works].each { |counts| counts.default = 0 }
  end
end
