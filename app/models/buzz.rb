# frozen_string_literal: true

class Buzz < ApplicationRecord
  validates :title, presence: true
  validates :published_at, presence: true
  validates :url, presence: true, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message:
    'URLに誤りがあります'
  }
end
