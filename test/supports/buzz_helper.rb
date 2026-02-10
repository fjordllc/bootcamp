# frozen_string_literal: true

module BuzzHelper
  def create_buzz(date, **options)
    Buzz.create!(
      title: options[:title] || "#{date}の記事",
      url: options[:url] || "https://www.example-#{date}-#{SecureRandom.hex(4)}.com",
      published_at: date,
      memo: options[:memo]
    )
  end

  def create_buzzes(dates)
    dates.map { |date| create_buzz(date) }
  end
end
