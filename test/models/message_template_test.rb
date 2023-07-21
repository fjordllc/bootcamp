# frozen_string_literal: true

require 'test_helper'

class MessageTemplateTest < ActiveSupport::TestCase
  setup do
    Struct.new('Event', :title, :description)
    @template = <<~'YAML'
      title: <%= "#{event.title}を開催します🎉" %>
      description: |
        <%= "#{event.description}" %>
    YAML
  end

  test '.load' do
    event = Struct::Event.new
    event.title       = 'xx月ミートアップ'
    event.description = "飛び込み参加ＯＫです。\r\n気軽にご参加下さい。"

    File.stub(:read, ->(_) { @template }) do
      result = MessageTemplate.load('', params: { event: })
      assert_equal 'xx月ミートアップを開催します🎉', result['title']
      assert_equal <<~TEXT, result['description']
        飛び込み参加ＯＫです。
        気軽にご参加下さい。
      TEXT
    end
  end

  test '#load' do
    event = Struct::Event.new
    event.title       = 'xx本・輪読会'
    event.description = "誰でも参加可能です。\r\nラジオ参加も歓迎です！"

    File.stub(:read, ->(_) { @template }) do
      result = MessageTemplate.new('').load({ event: })
      assert_equal 'xx本・輪読会を開催します🎉', result['title']
      assert_equal <<~TEXT, result['description']
        誰でも参加可能です。
        ラジオ参加も歓迎です！
      TEXT
    end
  end
end
