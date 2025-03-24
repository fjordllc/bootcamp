# frozen_string_literal: true

require 'test_helper'

class SubTabs::SurveysHelperTest < ActionView::TestCase
  test 'mentor_surveys_sub_tabs with active_tab: アンケート' do
    component_mock = Minitest::Mock.new
    component_mock.expect(:call, 'rendered component')

    SubTabsComponent.stub(:new, lambda { |tabs:, active_tab:|
      assert_equal 2, tabs.size
      assert_equal 'アンケート', tabs[0][:name]
      assert_equal mentor_surveys_path, tabs[0][:link]
      assert_equal '質問', tabs[1][:name]
      assert_equal mentor_survey_questions_path, tabs[1][:link]

      assert_equal 'アンケート', active_tab

      component_mock
    }) do
      stub(:render, lambda { |component|
        component.call
      }) do
        result = mentor_surveys_sub_tabs(active_tab: 'アンケート')

        assert_equal 'rendered component', result
      end
    end

    component_mock.verify
  end

  test 'mentor_surveys_sub_tabs with active_tab: 質問' do
    component_mock = Minitest::Mock.new
    component_mock.expect(:call, 'rendered component')

    SubTabsComponent.stub(:new, lambda { |tabs:, active_tab:|
      assert_equal 2, tabs.size
      assert_equal 'アンケート', tabs[0][:name]
      assert_equal mentor_surveys_path, tabs[0][:link]
      assert_equal '質問', tabs[1][:name]
      assert_equal mentor_survey_questions_path, tabs[1][:link]

      assert_equal '質問', active_tab

      component_mock
    }) do
      stub(:render, lambda { |component|
        component.call
      }) do
        result = mentor_surveys_sub_tabs(active_tab: '質問')

        assert_equal 'rendered component', result
      end
    end

    component_mock.verify
  end
end
