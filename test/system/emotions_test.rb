# frozen_string_literal: true

require 'application_system_test_case'

class EmotionsTest < ApplicationSystemTestCase
  test 'create a report with an emotion' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
    end

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    find('#positive').click

    click_button '提出'
    assert_text '日報を保存しました。'
    assert_selector 'img#positive'
  end

  test 'create a report with the negative emotion' do
    visit_with_auth '/reports/new', 'komagata'
    within('form[name=report]') do
      fill_in('report[title]', with: 'test title')
      fill_in('report[description]', with: 'test')
    end

    all('.learning-time')[0].all('.learning-time__started-at select')[0].select('07')
    all('.learning-time')[0].all('.learning-time__started-at select')[1].select('30')
    all('.learning-time')[0].all('.learning-time__finished-at select')[0].select('08')
    all('.learning-time')[0].all('.learning-time__finished-at select')[1].select('30')

    find('#negative').click

    click_button '提出'
    assert_text '日報を保存しました。'
    assert_selector 'img#negative'
    assert_text '困った時は'
  end
end
