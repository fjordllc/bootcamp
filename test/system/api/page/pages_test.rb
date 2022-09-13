# frozen_string_literal: true

require 'application_system_test_case'

class Check::PagesTest < ApplicationSystemTestCase
  test 'accessing a existent page returns 200' do
    visit_with_auth '/api/pages?page=1', 'komagata'
    expect(response.status).to eq(200)
  end
  test 'accessing a non-existent page returns 404' do
  end
end
