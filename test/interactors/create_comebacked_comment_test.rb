# frozen_string_literal: true

require 'test_helper'

class CreateComebackedCommentTest < ActiveSupport::TestCase
  test 'creates a comebacked comment' do
    user = users(:kyuukai)

    assert_difference 'Comment.count', 1 do
      CreateComebackedComment.call(user:)
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
