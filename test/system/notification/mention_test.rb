# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mention_helper'
require 'supports/report_helper'

class Notification::MentionTest < ApplicationSystemTestCase
  include MentionHelper
  include ReportHelper

  setup do
    @delivery_mode = AbstractNotifier.delivery_mode
    AbstractNotifier.delivery_mode = :normal
  end

  teardown do
    AbstractNotifier.delivery_mode = @delivery_mode
  end

  test 'mention from a answer' do
    post_mention = lambda { |answer|
      visit question_path(questions(:question8).id)
      within('.thread-comment-form__form') do
        fill_in('answer[description]', with: answer)
      end
      click_button 'コメントする'
    }
    assert_notify_mention(post_mention)
  end

  test 'mention from a comment' do
    post_mention = lambda { |comment|
      visit report_path(reports(:report1).id)
      within('.thread-comment-form__form') do
        fill_in('new_comment[description]', with: comment)
      end
      click_button 'コメントする'
    }
    assert_notify_mention(post_mention)
  end

  test 'mention from a production' do
    post_mention = lambda { |body|
      visit "#{new_product_path}?practice_id=#{practices(:practice5).id}"
      within('form[name=product]') do
        fill_in('product[body]', with: body)
      end
      click_button '提出する'
      assert_text "7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\nもし、7日以上経ってもレビューされない場合は、メンターにお問い合わせください。"
    }

    %w[hatsuno with-hyphen].each do |mention_target_login_name|
      assert exists_unread_mention_notification_after_posting_mention?('kimura', mention_target_login_name, post_mention)
      Product.last.destroy
    end
  end

  test 'mention from a question' do
    post_mention = lambda { |description|
      visit new_question_path
      fill_in 'question_title', with: 'メンション通知が送信されるかのテスト'
      fill_in 'question_description', with: description
      click_button '登録する'
    }

    assert_notify_mention(post_mention)
  end

  test 'mention from a report' do
    post_mention = lambda { |description|
      create_report('メンション通知が送信されるかのテスト', description, false)
    }

    %w[hatsuno with-hyphen].each do |mention_target_login_name|
      assert exists_unread_mention_notification_after_posting_mention?('kimura', mention_target_login_name, post_mention)
      Report.last.destroy
    end
  end
end
