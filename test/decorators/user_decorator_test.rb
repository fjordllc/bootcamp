# frozen_string_literal: true

require 'test_helper'
require 'supports/product_helper'
require 'active_decorator_test_case'

class UserDecoratorTest < ActiveDecoratorTestCase
  include ProductHelper

  setup do
    @admin_mentor_user = decorate(users(:komagata))
    @student_user = decorate(users(:hajime))
    @graduated_user = decorate(users(:sotugyou))
    @mentor_user = decorate(users(:mentormentaro))
    @hibernationed_user = decorate(users(:kyuukai))
    @japanese_user = decorate(users(:kimura))
    @american_user = decorate(users(:tom))
    @subdivision_not_registered_user = decorate(users(:hatsuno))
    @non_required_subject_completed_user = decorate(users(:harikirio))
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

    assert_nil @japanese_user.editor
    assert_equal @admin_mentor_user.editor_or_other_editor, 'textbringer'
    assert_equal @student_user.editor_or_other_editor, 'VSCode'
  end

  test '#niconico_calendar' do
    start_date = Date.new(2024, 3, 1)
    last_date = Date.new(2024, 3, 31)
    dates_and_reports = (start_date..last_date).map do |date|
      { report: nil, date:, emotion: nil }
    end
    calendar = niconico_calendar(dates_and_reports)

    assert_equal(5, calendar.first.count { |set| set[:date].nil? })
  end

  test '#user_icon_frame_class' do
    new_user = decorate(users(:otameshi))
    standard_user = decorate(users(:kimura))

    def new_user.primary_role = 'student'
    def new_user.joining_status = 'new-user'

    def standard_user.primary_role = 'student'
    def standard_user.joining_status = ''

    assert_equal 'a-user-role is-student is-new-user', new_user.user_icon_frame_class
    assert_equal 'a-user-role is-student', standard_user.user_icon_frame_class
  end
end
