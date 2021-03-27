# frozen_string_literal: true

require 'application_system_test_case'
require 'supports/mention_helper'

module Mention
  class ProductsTest < ApplicationSystemTestCase
    include MentionHelper

    test 'mention from a production' do
      post_mention = lambda { |body|
        visit "#{new_product_path}?practice_id=#{practices(:practice5).id}"
        within('#new_product') do
          fill_in('product[body]', with: body)
        end
        click_button '提出する'
        assert_text "提出物を提出しました。7日以内にメンターがレビューしますので、次のプラクティスにお進みください。\n7日以上待ってもレビューされない場合は、気軽にメンターにメンションを送ってください。"
      }

      %w[hatsuno].each do |mention_target_login_name|
        assert exists_unread_mention_notification_after_posting_mention?(
          'kimura', mention_target_login_name, post_mention
        )
      end
    end
  end
end
