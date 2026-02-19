# frozen_string_literal: true

require 'application_system_test_case'

module Home
  class HibernationCountTest < ApplicationSystemTestCase
    test 'show hibernation count for past-hibernated user' do
      visit_with_auth '/', 'hukki'
      assert_text 'あなたの休会回数'
    end

    test 'not show hibernation count for never-hibernated user' do
      visit_with_auth '/', 'kimura'
      assert_no_text 'あなたの休会回数'
    end

    test 'not show hibernation count for mentor' do
      visit_with_auth '/', 'mentormentaro'
      assert_no_text 'あなたの休会回数'
    end

    test 'not show hibernation count for administrator' do
      visit_with_auth '/', 'komagata'
      assert_no_text 'あなたの休会回数'
    end
  end
end