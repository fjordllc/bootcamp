# frozen_string_literal: true

class Memo < ApplicationRecord
  validates :date, uniqueness: true

  def self.one_month_memos(beggining_of_this_month)
    days_of_this_month = beggining_of_this_month..beggining_of_this_month.end_of_month
    where(date: days_of_this_month).index_by do |memo|
      I18n.l(memo[:date], format: :ymd_hy)
    end
  end
end
