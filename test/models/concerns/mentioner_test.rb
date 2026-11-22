# frozen_string_literal: true

require 'test_helper'

class MentionerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  MENTION_TARGETS = %w[hatsuno with-hyphen].freeze

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
    @writer = users(:kimura)
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'notify mentioned users when an answer is posted' do
    assert_notify_mention('kimuraさんのQ&A「テストの質問」へのコメント') do |description|
      Answer.create!(user: @writer, question: questions(:question8), description:)
    end
  end

  test 'notify mentioned users when a comment is posted' do
    assert_notify_mention('komagataさんの日報「作業週1日目」へのコメント') do |description|
      Comment.create!(user: @writer, commentable: reports(:report1), description:)
    end
  end

  test 'notify mentioned users when a product is submitted' do
    assert_notify_mention('kimuraさんの提出物「Linuxのファイル操作の基礎を覚える」') do |body|
      Product.where(user: @writer, practice: practices(:practice5)).destroy_all
      Product.create!(user: @writer, practice: practices(:practice5), body:, published_at: Time.current)
    end
  end

  test 'notify mentioned users when a question is posted' do
    assert_notify_mention('kimuraさんのQ&A「プラクティス選択なし」') do |description|
      Question.create!(user: @writer, title: 'メンション通知が送信されるかのテスト', description:)
    end
  end

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

  test '#where_mention does not raise when the commentable has no user' do
    comment = comments(:comment1)
    comment.commentable.stub(:user, nil) do
      assert_nothing_raised { comment.where_mention }
    end
  end

  private

  def assert_notify_mention(where)
    MENTION_TARGETS.each do |login_name|
      receiver = User.find_by!(login_name:)
      mentions = Notification.where(user: receiver, sender: @writer, kind: :mentioned)

      assert_difference -> { mentions.count }, 1, "#{login_name}へメンションの通知が届くこと" do
        perform_enqueued_jobs { yield "@#{login_name} にメンション通知がいくかのテスト" }
      end
      assert_equal "#{where}でkimuraさんからメンションがきました。", mentions.order(:created_at).last.message
    end
  end
end
