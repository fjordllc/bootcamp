# frozen_string_literal: true

module BuzzHelper
  def create_buzz(date, memo = nil)
    Buzz.create!(
      title: "#{date}の記事",
      url: 'https://www.example.com',
      published_at: date,
      memo:
    )
  end
end
