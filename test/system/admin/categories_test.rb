# frozen_string_literal: true

require 'application_system_test_case'

class Admin::CategoriesTest < ApplicationSystemTestCase
  setup { login_user 'komagata', 'testtest' }

  test 'show listing categories' do
    visit '/admin/categories'
    assert_equal 'カテゴリー | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'create category' do
    visit '/admin/categories/new'
    within 'form[name=category]' do
      fill_in 'category[name]', with: 'テストカテゴリー'
      fill_in 'category[slug]', with: 'test-category'
      fill_in 'category[description]', with: 'テストのカテゴリーです。'
      click_button '登録する'
    end
    assert_text 'カテゴリーを作成しました。'
  end

  test 'update category from course page' do
    visit course_practices_path(courses(:course1))
    first('.categories-item__edit').click
    within 'form[name=category]' do
      fill_in 'category[name]', with: 'テストカテゴリー'
      fill_in 'category[slug]', with: 'test-category'
      fill_in 'category[description]', with: 'テストのカテゴリーです。'
      click_button '更新する'
    end
    assert_text 'カテゴリーを更新しました。'
    assert_current_path course_practices_path(courses(:course1))
  end

  test 'update category from admin categories' do
    visit  admin_categories_path
    first('.a-button.is-sm.is-primary.is-icon').click
    within 'form[name=category]' do
      fill_in 'category[name]', with: 'テストカテゴリー'
      fill_in 'category[slug]', with: 'test-category'
      fill_in 'category[description]', with: 'テストのカテゴリーです。'
      click_button '更新する'
    end
    assert_text 'カテゴリーを更新しました。'
    assert_current_path admin_categories_path
  end

  test 'delete category' do
    visit '/admin/categories'
    within('.admin-table__item:first-child') do
      accept_confirm do
        find('.js-delete').click
      end
    end
    assert_no_text '学習の準備'
  end
end
