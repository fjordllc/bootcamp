# frozen_string_literal: true

require 'test_helper'

class UserDecoratorTest < ActiveSupport::TestCase
  include ActionView::TestCase::Behavior

  def setup
    ActiveDecorator::ViewContext.push(controller.view_context)
    @admin_mentor_user = ActiveDecorator::Decorator.instance.decorate(users(:komagata))
    @student_user = ActiveDecorator::Decorator.instance.decorate(users(:hajime))
    @graduated_user = ActiveDecorator::Decorator.instance.decorate(users(:sotugyou))
    @admin_user = ActiveDecorator::Decorator.instance.decorate(users(:adminonly))
    @adviser_user = ActiveDecorator::Decorator.instance.decorate(users(:advijirou))
    @mentor_user = ActiveDecorator::Decorator.instance.decorate(users(:mentormentaro))
    @trainee_user = ActiveDecorator::Decorator.instance.decorate(users(:kensyu))
    @retired_user = ActiveDecorator::Decorator.instance.decorate(users(:taikai))
    @hibernationed_user = ActiveDecorator::Decorator.instance.decorate(users(:kyuukai))
    @japanese_user = ActiveDecorator::Decorator.instance.decorate(users(:kimura))
    @american_user = ActiveDecorator::Decorator.instance.decorate(users(:tom))
    @subdivision_not_registered_user = ActiveDecorator::Decorator.instance.decorate(users(:hatsuno))
  end

  test '#staff_roles' do
    assert_equal '管理者、メンター', @admin_mentor_user.staff_roles
    assert_equal '', @student_user.staff_roles
  end

  test '#icon_title' do
    assert_equal 'komagata (Komagata Masaki): 管理者、メンター', @admin_mentor_user.icon_title
    assert_equal 'hajime (Hajime Tayo)', @student_user.icon_title
  end

  test '#long_name' do
    assert_equal 'hajime (ハジメ タヨ)', @student_user.long_name
  end

  test '#enrollment_period' do
    assert_equal "<span> #{@student_user.elapsed_days}日目 </span><a href=\"/generations/#{@student_user.generation}\">#{@student_user.generation}期生</a>",
                 @student_user.enrollment_period

    assert_equal "<span> (#{l @graduated_user.graduated_on}卒業 #{@graduated_user.elapsed_days}日)" \
                  " </span><a href=\"/generations/#{@graduated_user.generation}\">#{@graduated_user.generation}期生</a>",
                 @graduated_user.enrollment_period
  end

  test '#roles_to_s' do
    assert_equal '管理者、メンター', @admin_mentor_user.roles_to_s
    assert_equal '', @student_user.roles_to_s
    assert_equal '卒業生', @graduated_user.roles_to_s
    assert_equal '管理者', @admin_user.roles_to_s
    assert_equal 'アドバイザー', @adviser_user.roles_to_s
    assert_equal 'メンター', @mentor_user.roles_to_s
    assert_equal '研修生', @trainee_user.roles_to_s
    assert_equal '退会ユーザー', @retired_user.roles_to_s
    assert_equal '休会ユーザー', @hibernationed_user.roles_to_s
  end

  test '#subdivisions_of_country' do
    assert_includes @japanese_user.subdivisions_of_country, %w[北海道 01]
    assert_includes @american_user.subdivisions_of_country, %w[アラスカ州 AK]
  end

  test '#address' do
    assert_equal '東京都 (日本)', @japanese_user.address
    assert_equal 'ニューヨーク州 (米国)', @american_user.address
    assert_equal '日本', @subdivision_not_registered_user.address
  end

  test '#hibernation_days' do
    travel_to Time.zone.local(2020, 2, 1, 9, 0, 0) do
      assert_equal 31, @hibernationed_user.hibernation_days
    end
  end

  test '#retire_countdown' do
    travel_to Time.zone.local(2020, 6, 24, 9, 0, 0) do
      assert_equal 7, @hibernationed_user.retire_countdown
    end
  end

  test '#retire_deadline' do
    travel_to Time.zone.local(2020, 7, 1, 8, 1, 0) do # 自動退会日まで1時間を切った場合。
      assert_equal '2020年07月01日(水) 09:00 (自動退会まであと59分)', @hibernationed_user.retire_deadline
    end

    travel_to Time.zone.local(2020, 6, 30, 10, 0, 0) do # 自動退会日まで24時間を切った場合。
      assert_equal '2020年07月01日(水) 09:00 (自動退会まであと23時間)', @hibernationed_user.retire_deadline
    end

    travel_to Time.zone.local(2020, 6, 24, 9, 0, 0) do # 自動退会日1週間を切った場合。
      assert_equal '2020年07月01日(水) 09:00 (自動退会まであと7日)', @hibernationed_user.retire_deadline
    end

    travel_to Time.zone.local(2020, 1, 1, 9, 0, 0) do # 自動退会日6ヶ月前 ~ 1週間を切るまでの場合。
      assert_equal '2020年07月01日(水) 09:00 (自動退会まであと182日)', @hibernationed_user.retire_deadline
    end
  end
end
