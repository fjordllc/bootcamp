# frozen_string_literal: true

require 'test_helper'

class ComebackUserTest < ActiveSupport::TestCase
  test 'skips subscription in staging environment' do
    user = users(:kyuukai)

    original_db_name = ENV['DB_NAME']
    ENV['DB_NAME'] = 'bootcamp_staging'

    Rails.env.stub(:production?, true) do
      assert_nothing_raised do
        ComebackUser.call(user:)
      end
    end

    assert_nil user.reload.hibernated_at
  ensure
    ENV['DB_NAME'] = original_db_name
  end

  test 'creates a comebacked comment' do
    user = users(:kyuukai)

    assert_difference 'Comment.count', 1 do
      ComebackUser.call(user:)
    end
    comment = Comment.last
    description = "お帰りなさい！！復会ありがとうございます。\n" \
          '休会中に何か変わったことがあれば、再びスムーズに学び始めることができるように全力でサポートします。' \
          "何か困ったことや質問があれば、メンターの皆さんに遠慮なくご相談ください。\n\n" \
          "またフィヨルドブートキャンプの Discord のサーバーに入室できるように、再度、Doc にある Discord の招待 URL にアクセスをお願いします。\n" \
          '<https://bootcamp.fjord.jp/practices/129#url>'
    assert_equal user.id, comment.commentable.user_id
    assert_equal users(:pjord).id, comment.user_id
    assert_equal description, comment.body
  end
end
