# frozen_string_literal: true

require 'application_system_test_case'

class Admin::CategoriesTest < ApplicationSystemTestCase
  test 'show listing categories' do
    visit_with_auth '/admin/categories', 'komagata'
    assert_equal '管理ページ | FBC', title
  end

  test 'show category page' do
    visit_with_auth admin_category_path(categories(:category2)), 'komagata'
    assert_equal 'Mac OS X | FBC', title
    first('.card-list-item').assert_text 'OS X Mountain Lionをクリーンインストールする'
  end

  test 'create category' do
    visit_with_auth '/admin/categories/new', 'komagata'
    within 'form[name=category]' do
      fill_in 'category[name]', with: 'テストカテゴリー'
      fill_in 'category[slug]', with: 'test-category'
      fill_in 'category[description]', with: 'テストのカテゴリーです。'
      click_button '登録する'
    end
    assert_text 'カテゴリーを作成しました。'
  end

  test 'update category from course page' do
    visit_with_auth course_practices_path(courses(:course1)), 'komagata'
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
    visit_with_auth admin_categories_path, 'komagata'
    first('.spec-edit').click
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
    visit_with_auth '/admin/categories', 'komagata'
    within('.admin-table__item:first-child') do
      accept_confirm do
        find('.js-delete').click
      end
    end
    assert_no_text '学習の準備'
  end
end
