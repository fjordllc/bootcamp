# frozen_string_literal: true

require 'test_helper'

module Taggable
  class TagTest < ActiveSupport::TestCase
    setup do
      # Taggable modeuleをicnludeしているUser classを利用する
      @user = users(:komagata)
    end

    test 'valid contians_space' do
      # 先頭と末尾の空白文字はacts-as-taggable-on(tag_list)で自動的に取り除くため
      # ` ` や ` a`, ' a' はテストしない
      [
        '半角スペースは 使えない',
        '全角スペースも　使えない',
        '先頭と末尾の　',
        '　全角スペースは自動で取り除かれない'
      ].each do |tag|
        assert_raise(ActiveRecord::RecordInvalid) { @user.update!(tag_list: [tag]) }
      end
    end

    test 'valid contains_one_dot_only' do
      assert_raise(ActiveRecord::RecordInvalid) { @user.update!(tag_list: ['.']) }
    end
  end
end
