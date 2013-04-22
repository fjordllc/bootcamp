require 'spec_helper'

feature 'Switch Practices', js: true do
  scenario 'not exist when not signed in' do
    page.should_not have_content "#display-switch"
  end
end
