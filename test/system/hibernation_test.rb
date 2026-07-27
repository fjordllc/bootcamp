# frozen_string_literal: true

require 'application_system_test_case'

class HibernationTest < ApplicationSystemTestCase
  test 'can not access hibernation without login' do
    visit '/hibernation'
    assert_equal 'FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'hibernate' do
    visit_with_auth new_hibernation_path, 'hatsuno'
    within('form[name=hibernation]') do
      fill_in(
        'hibernation[scheduled_return_on]',
        with: (Date.current + 30)
      )
      fill_in('hibernation[reason]', with: 'test')
    end

    VCR.use_cassette 'subscription/update', vcr_options do
      find('.check-box-to-read').click
      js_code = <<-JS
        const btn = document.querySelector('.js-hibernation-agreements-submit');
        btn.classList.remove('is-disabled');
        btn.classList.add('is-danger');
        btn.click();
      JS
      page.execute_script(js_code)
      accept_confirm do
        click_on '休会する'
      end
      assert_text '休会手続きが完了しました'
    end
  end

  test 'hibernate without scheduled_return_on' do
    visit_with_auth new_hibernation_path, 'hatsuno'
    within('form[name=hibernation]') do
      fill_in('hibernation[reason]', with: 'test')
    end

    find('.check-box-to-read').click
    js_code = <<-JS
      const btn = document.querySelector('.js-hibernation-agreements-submit');
      btn.classList.remove('is-disabled');
      btn.classList.add('is-danger');
      btn.click();
    JS
    page.execute_script(js_code)
    accept_confirm do
      click_on '休会する'
    end
    assert_text '復帰予定日を入力してください'
  end

  test 'removed a pair_work by hibernate' do
    pair_work = pair_works(:pair_work1)
    visit_with_auth new_hibernation_path, 'kimura'
    within('form[name=hibernation]') do
      fill_in(
        'hibernation[scheduled_return_on]',
        with: (Date.current + 30)
      )
      fill_in('hibernation[reason]', with: 'test')
    end

    find('.check-box-to-read').click
    js_code = <<-JS
      const btn = document.querySelector('.js-hibernation-agreements-submit');
      btn.classList.remove('is-disabled');
      btn.classList.add('is-danger');
      btn.click();
    JS
    page.execute_script(js_code)
    accept_confirm do
      click_on '休会する'
    end

    assert_not PairWork.exists?(pair_work.id)
  end
end
