# frozen_string_literal: true

require 'test_helper'

class Users::RegisterAddressPartialTest < ActionView::TestCase
  test 'hides country and subdivision fields when address is not registered' do
    render_register_address(users(:komagata))

    assert_select 'input[name=register_address][value=no][checked=checked]'
    assert_select '#country-form.is-hidden'
    assert_select '#subdivision-form.is-hidden'
  end

  test 'renders country and subdivision fields when address is registered' do
    render_register_address(users(:kimura))

    assert_select 'input[name=register_address][value=yes][checked=checked]'
    assert_select '#country-form'
    assert_select '#country-form.is-hidden', false
    assert_select 'select#country-select[name="user[country_code]"] option[selected=selected]', text: '日本'
    assert_select '#subdivision-form'
    assert_select '#subdivision-form.is-hidden', false
    assert_select 'select#subdivision-select[name="user[subdivision_code]"] option', text: '北海道'
  end

  private

  def render_register_address(user)
    form_with(model: user, url: current_user_path) do |f|
      render partial: 'users/form/register_address', locals: { f:, user: }
    end
  end
end
