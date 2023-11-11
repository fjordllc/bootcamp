# frozen_string_literal: true

require 'test_helper'

class MessageTemplateTest < ActiveSupport::TestCase
  test '.load' do
    event = {
      title: 'xx月ミートアップ',
      description: "飛び込み参加ＯＫです。\r\n気軽にご参加下さい。"
    }

    template = <<~'YAML'
      title: <%= "#{event[:title]}を開催します🎉" %>
      description: |
        <%= "#{event[:description]}" %>
    YAML

    File.stub(:read, ->(_) { template }) do
      result = MessageTemplate.load('', params: { event: })
      assert_equal 'xx月ミートアップを開催します🎉', result['title']
      assert_equal <<~TEXT, result['description']
        飛び込み参加ＯＫです。
        気軽にご参加下さい。
      TEXT
    end
  end

  test '#load' do
    event = {
      title: 'xx本・輪読会',
      description: "誰でも参加可能です。\r\nラジオ参加も歓迎です！"
    }

    template = <<~'YAML'
      title: <%= "#{event[:title]}を開催します🎉" %>
      description: |
        <%= "#{event[:description]}" %>
    YAML

    File.stub(:read, ->(_) { template }) do
      result = MessageTemplate.new('').load({ event: })
      assert_equal 'xx本・輪読会を開催します🎉', result['title']
      assert_equal <<~TEXT, result['description']
        誰でも参加可能です。
        ラジオ参加も歓迎です！
      TEXT
    end
  end
end
