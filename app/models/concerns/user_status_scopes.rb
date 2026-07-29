# frozen_string_literal: true

module UserStatusScopes
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
  end
end
