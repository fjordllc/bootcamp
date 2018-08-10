module Checkable
  extend ActiveSupport::Concern

  included do
    has_many :checks, as: :checkable, dependent: :delete_all
  end

  def checked?
    checks.present?
  end
end
