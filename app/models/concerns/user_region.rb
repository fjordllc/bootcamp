# frozen_string_literal: true

# ユーザーの居住地域の入力検証に関する責務をまとめたもの。
module UserRegion
  extend ActiveSupport::Concern

  included do
    before_validation :convert_blank_of_address_to_nil

    validates :country_code, inclusion: { in: ISO3166::Country.codes }, allow_nil: true
    validates :subdivision_code, inclusion: { in: ->(user) { user.subdivision_codes } }, allow_nil: true, if: -> { country_code.present? }
  end

  private

  def convert_blank_of_address_to_nil
    self.country_code = nil if country_code.blank?
    self.subdivision_code = nil if subdivision_code.blank?
  end
end
