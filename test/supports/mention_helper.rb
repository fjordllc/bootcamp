# frozen_string_literal: true

require 'supports/login_helper'
require 'supports/notification_helper'

module MentionHelper
  include LoginHelper
  include NotificationHelper

  def exists_unread_mention_notification_after_posting_mention?(
    writer_login_name, mention_target_login_name, post_mention
  )
    login_user writer_login_name, 'testtest'
    assert_text 'ダッシュボード'
    post_mention.call("@#{mention_target_login_name} にメンション通知がいくかのテスト")
    logout

    login_user mention_target_login_name, 'testtest'
    assert_text 'ダッシュボード'
    exists_unread_notification?(make_mention_notification_message(writer_login_name))
  end

  def assert_notify_mention(post_mention)
    %w[hatsuno with-hyphen].each do |mention_target_login_name|
      assert exists_unread_mention_notification_after_posting_mention?(
        'kimura', mention_target_login_name, post_mention
      )
    end
  end
end
