# frozen_string_literal: true

require 'test_helper'

class Searcher::ConfigurationTest < ActiveSupport::TestCase
  test 'configurations returns all configurations' do
    configs = Searcher::Configuration.configurations

    assert configs.is_a?(Hash)
    assert_includes configs.keys, :practice
    assert_includes configs.keys, :user
    assert_includes configs.keys, :report
    assert_includes configs.keys, :product
    assert_includes configs.keys, :announcement
    assert_includes configs.keys, :page
    assert_includes configs.keys, :question
    assert_includes configs.keys, :answer
    assert_includes configs.keys, :correct_answer
    assert_includes configs.keys, :comment
    assert_includes configs.keys, :event
    assert_includes configs.keys, :regular_event
  end

  test 'get returns specific configuration' do
    practice_config = Searcher::Configuration.get(:practice)

    assert_equal Practice, practice_config[:model]
    assert_equal %i[title description goal], practice_config[:columns]
    assert_empty practice_config[:includes]
    assert_equal 'プラクティス', practice_config[:label]
  end

  test 'get returns user configuration with correct columns' do
    user_config = Searcher::Configuration.get(:user)

    assert_equal User, user_config[:model]
    assert_includes user_config[:columns], :login_name
    assert_includes user_config[:columns], :name
    assert_includes user_config[:columns], :name_kana
    assert_includes user_config[:columns], :description
    assert_equal 'ユーザー', user_config[:label]
  end

  test 'get returns nil for non-existent type' do
    config = Searcher::Configuration.get(:non_existent)

    assert_nil config
  end

  test 'available_types returns all configuration keys' do
    types = Searcher::Configuration.available_types

    expected_types = %i[practice user report product announcement page question answer correct_answer comment event regular_event]
    assert_equal expected_types.sort, types.sort
  end

  test 'available_types_for_select returns options for select tag' do
    options = Searcher::Configuration.available_types_for_select

    assert options.is_a?(Array)
    # 最初の要素は「すべて」
    assert_equal ['すべて', :all], options.first

    # 各設定がオプションに含まれる
    assert_includes options, ['プラクティス', :practice]
    assert_includes options, ['ユーザー', :user]
    assert_includes options, ['日報', :report]
    assert_includes options, ['提出物', :product]
    assert_includes options, ['お知らせ', :announcement]
    assert_includes options, ['Docs', :page]
    assert_includes options, ['Q&A', :question]
    assert_includes options, ['回答', :answer]
    assert_includes options, ['模範回答', :correct_answer]
    assert_includes options, ['コメント', :comment]
    assert_includes options, ['イベント', :event]
    assert_includes options, ['定期イベント', :regular_event]
  end

  test 'configurations have required keys' do
    Searcher::Configuration.configurations.each do |type, config|
      assert config.key?(:model), "#{type} config missing :model key"
      assert config.key?(:columns), "#{type} config missing :columns key"
      assert config.key?(:includes), "#{type} config missing :includes key"
      assert config.key?(:label), "#{type} config missing :label key"
    end
  end

  test 'configurations have valid models' do
    Searcher::Configuration.configurations.each do |type, config|
      model = config[:model]
      assert model.is_a?(Class), "#{type} config :model should be a class"
      assert model < ApplicationRecord, "#{type} config :model should inherit from ApplicationRecord"
    end
  end

  test 'configurations have valid columns arrays' do
    Searcher::Configuration.configurations.each do |type, config|
      columns = config[:columns]
      assert columns.is_a?(Array), "#{type} config :columns should be an array"
      assert columns.all? { |col| col.is_a?(Symbol) }, "#{type} config :columns should contain symbols"
    end
  end

  test 'configurations have valid includes arrays' do
    Searcher::Configuration.configurations.each do |type, config|
      includes = config[:includes]
      assert includes.is_a?(Array), "#{type} config :includes should be an array"
    end
  end

  test 'configurations have valid labels' do
    Searcher::Configuration.configurations.each do |type, config|
      label = config[:label]
      assert label.is_a?(String), "#{type} config :label should be a string"
      assert_not label.empty?, "#{type} config :label should not be empty"
    end
  end
end
