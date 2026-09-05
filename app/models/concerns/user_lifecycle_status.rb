# frozen_string_literal: true

# ユーザーの在籍ライフサイクル(在校・卒業・休会・退会)に関する責務をまとめたもの。
module UserLifecycleStatus
  extend ActiveSupport::Concern

  included do
    scope :in_school, -> { where(graduated_on: nil) }
    scope :graduated, -> { where.not(graduated_on: nil) }
    scope :hibernated, -> { where.not(hibernated_at: nil) }
    scope :unhibernated, -> { where(hibernated_at: nil) }
    scope :retired, -> { where.not(retired_on: nil) }
    scope :unretired, -> { where(retired_on: nil) }
    scope :hibernated_for, ->(period) { where(hibernated_at: nil..period.ago) }
    scope :auto_retire, -> { where(auto_retire: true) }
    scope :year_end_party, lambda {
      where(
        hibernated_at: nil,
        retired_on: nil
      )
    }
  end

  class_methods do
    def tags
      unretired.unhibernated.all_tag_counts(order: 'count desc, name asc')
    end
  end
end
