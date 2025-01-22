# frozen_string_literal: true

require 'application_system_test_case'

class Mentor::CategoriesTest < ApplicationSystemTestCase
  test 'show listing categories' do
    visit_with_auth '/mentor/categories', 'mentormentaro'
    assert_equal 'メンターページ | FBC', title
  end

  test 'show category page' do
    visit_with_auth mentor_category_path(categories(:category2)), 'mentormentaro'
    assert_equal 'Mac OS X | FBC', title
    first('.card-list-item').assert_text 'OS X Mountain Lionをクリーンインストールする'
  end

  test 'create a category' do
    visit_with_auth '/mentor/categories/new', 'mentormentaro'
    within 'form[name=category]' do
      fill_in 'category[name]', with: 'テストカテゴリー'
      fill_in 'category[slug]', with: 'test-category'
      fill_in 'category[description]', with: 'テストのカテゴリーです。'
      click_button '登録する'
    end
    assert_text 'カテゴリーを作成しました。'
  end

  test 'cannot create category without category name' do
    visit_with_auth new_mentor_category_path, 'komagata'
    within 'form[name=category]' do
      fill_in 'category[slug]', with: 'test-category'
      fill_in 'category[description]', with: 'テストのカテゴリーです。'
      click_button '登録する'
    end
    assert_text '入力内容にエラーがありました'
    assert_text '名前を入力してください'
  end

  test 'cannot create category without category slug' do
    visit_with_auth new_mentor_category_path, 'komagata'
    within 'form[name=category]' do
      fill_in 'category[name]', with: 'テストカテゴリー'
      fill_in 'category[description]', with: 'テストのカテゴリーです。'
      click_button '登録する'
    end
    assert_text '入力内容にエラーがありました'
    assert_text 'URLスラッグを入力してください'
  end

  test 'update category from course page' do
    visit_with_auth course_practices_path(courses(:course1)), 'mentormentaro'
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

  test 'update category from mentor categories' do
    visit_with_auth mentor_categories_path, 'mentormentaro'
    first('.spec-edit').click
    within 'form[name=category]' do
      fill_in 'category[name]', with: 'テストカテゴリー'
      fill_in 'category[slug]', with: 'test-category'
      fill_in 'category[description]', with: 'テストのカテゴリーです。'
      click_button '更新する'
    end
    assert_text 'カテゴリーを更新しました。'
    assert_current_path mentor_categories_path
  end

  test 'delete category' do
    visit_with_auth "/mentor/categories/#{categories(:category1).id}/edit", 'mentormentaro'
    click_on '削除'
    page.driver.browser.switch_to.alert.accept
    assert_text 'カテゴリーを削除しました。'
    assert_no_text '学習の準備'
  end

  test 'admin and mentor can access category practice sorting page' do
    category = Category.find_by(name: '学習の準備')

    visit_with_auth mentor_categories_path, 'komagata'
    assert_text '学習の準備'
    find("a[href='/mentor/categories/#{category.id}/practices']").click
    assert_text '学習の準備カテゴリーのプラクティス並び替え'

    visit_with_auth mentor_categories_path, 'mentormentaro'
    assert_text '学習の準備'
    find("a[href='/mentor/categories/#{category.id}/practices']").click
    assert_text '学習の準備カテゴリーのプラクティス並び替え'
  end

  test 'should display practice count correctly' do
    category_name = '学習の準備'
    category = Category.find_by(name: category_name)
    practice_count = category.practices.length

    visit_with_auth '/mentor/categories', 'komagata'
    assert_text "#{category_name}(#{practice_count})"
  end
end
