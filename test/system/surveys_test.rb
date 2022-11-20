# frozen_string_literal: true

require 'application_system_test_case'

class SurveysTest < ApplicationSystemTestCase
  setup do
    @survey = surveys(:one)
  end

  test 'visiting the index' do
    visit surveys_url
    assert_selector 'h1', text: 'Surveys'
  end

  test 'creating a Survey' do
    visit surveys_url
    click_on 'New Survey'

    fill_in 'End at', with: @survey.end_at
    fill_in 'Title', with: @survey.title
    fill_in 'User', with: @survey.user_id
    click_on 'Create Survey'

    assert_text 'Survey was successfully created'
    click_on 'Back'
  end

  test 'updating a Survey' do
    visit surveys_url
    click_on 'Edit', match: :first

    fill_in 'End at', with: @survey.end_at
    fill_in 'Title', with: @survey.title
    fill_in 'User', with: @survey.user_id
    click_on 'Update Survey'

    assert_text 'Survey was successfully updated'
    click_on 'Back'
  end

  test 'destroying a Survey' do
    visit surveys_url
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Survey was successfully destroyed'
  end
end
