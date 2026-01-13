# frozen_string_literal: true

require 'test_helper'

class MentionerTest < ActiveSupport::TestCase
  test '#notify_all_mention_user' do
    markdown = <<~TEXT
       @komagata
       文中に > を含む @machida

      ```
      @hatsuno
      ```
      `@kananashi`

      > @sotugyou\n\n
      > 改行を含む
      @hajime

      > テキストエリアと
      最終行が一致 @kensyu
    TEXT

    report = Report.create!(
      user: users(:hajime),
      reported_on: Time.zone.today,
      title: 'メンションテスト',
      description: markdown
    )

    assert_equal %w[komagata machida], report.notify_all_mention_user.map(&:login_name).sort
  end
end
