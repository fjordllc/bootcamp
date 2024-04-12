# frozen_string_literal: true

require 'test_helper'
require 'active_decorator_test_case'

class UserDecoratorTest < ActiveDecoratorTestCase
  setup do
    @admin_mentor_user = decorate(users(:komagata))
    @student_user = decorate(users(:hajime))
    @graduated_user = decorate(users(:sotugyou))
    @mentor_user = decorate(users(:mentormentaro))
    @hibernationed_user = decorate(users(:kyuukai))
    @japanese_user = decorate(users(:kimura))
    @american_user = decorate(users(:tom))
    @subdivision_not_registered_user = decorate(users(:hatsuno))
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
      assert_nil @student_user.hibernation_days
    end
  end

  test '#other_editor_checked?' do
    editors = User.editors.keys
    @admin_mentor_user.editor = 99
    @student_user.editor = 0

    assert @admin_mentor_user.other_editor_checked?(editors)
    assert_not @student_user.other_editor_checked?(editors)
  end

  test '#editor_or_other_editor' do
    @admin_mentor_user.other_editor = 'textbringer'
    @admin_mentor_user.editor = 99
    @student_user.editor = 0

    assert_equal @japanese_user.editor, nil
    assert_equal @admin_mentor_user.editor_or_other_editor, 'textbringer'
    assert_equal @student_user.editor_or_other_editor, 'VSCode'
  end
end
