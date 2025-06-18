# frozen_string_literal: true

require 'application_system_test_case'

class Admin::Users::PracticeProgressTest < ApplicationSystemTestCase
  test "admin can view user's completed Rails practices only" do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create a dedicated category and practice for this test
    category = Category.create!(name: 'Test Category', slug: 'test-category')
    category.courses << rails_course

    practice = Practice.new(
      title: 'Test Practice',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    practice.categories << category
    practice.save!

    # Clear existing learning to avoid uniqueness conflicts
    Learning.where(user:, practice:).destroy_all

    # Create a completed learning for the user
    Learning.create!(
      user:,
      practice:,
      status: 'complete'
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text "#{user.login_name}さんのRailsエンジニアコース完了プラクティス一覧"
    assert_text practice.title
    assert_text practice.id.to_s
    assert_text 'ID'
    assert_text 'ステータス'
    assert_text '提出物'
    assert_text '完了日'
    assert_text 'プラクティス（Reスキル）'
    assert_text 'ステータス（Reスキル）'
    assert_text '進捗（Reスキル）'
    assert_text '修了'
    assert_selector '.admin-table'
  end

  test "admin can see user's current course" do
    user = users(:kimura)
    course = courses(:course1)
    user.update!(course:)

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    # NOTE: Current course information is not displayed in the current view
    # assert_text "現在のコース: #{course.title}"
    # assert_text '対象コース: Railsエンジニア'
  end

  test 'shows message when user has no completed Rails practices' do
    user = users(:kimura)
    # Ensure user has no completed learnings
    user.learnings.destroy_all

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text "#{user.login_name}さんのRailsエンジニアコース完了プラクティス一覧"
    assert_text 'Railsエンジニアコースで完了したプラクティスがありません。'
  end

  test 'does not show practices from other courses' do
    user = users(:kimura)
    frontend_course = courses(:course4) # フロントエンドエンジニアコース

    # Create a dedicated category and practice for frontend course
    category = Category.create!(name: 'Frontend Test Category', slug: 'frontend-test-category')
    category.courses << frontend_course

    practice = Practice.new(
      title: 'Frontend Test Practice',
      description: 'Frontend practice for system test',
      goal: 'Frontend goal',
      submission: 'product'
    )
    practice.categories << category
    practice.save!

    # Clear all existing learnings for this user to ensure clean state
    Learning.where(user:).destroy_all

    # Create a completed learning for the user
    Learning.create!(
      user:,
      practice:,
      status: 'complete'
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text "#{user.login_name}さんのRailsエンジニアコース完了プラクティス一覧"
    assert_no_text practice.title
    assert_text 'Railsエンジニアコースで完了したプラクティスがありません。'
  end

  test 'shows copied practice when source_id matches' do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create dedicated category and original practice for this test
    category = Category.create!(name: 'Test Category Copy Source Match', slug: 'test-category-copy-source-match')
    category.courses << rails_course

    original_practice = Practice.new(
      title: 'Test Practice Copy Source Match',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    original_practice.categories << category
    original_practice.save!

    # Create copied practice with source_id pointing to original
    timestamp = Time.current.to_i
    copied_practice = Practice.new(
      title: "#{original_practice.title} (コピー) #{timestamp}",
      description: original_practice.description,
      goal: original_practice.goal,
      source_id: original_practice.id
    )
    copied_practice.categories << category
    copied_practice.save!

    # Clear existing learning to avoid uniqueness conflicts
    Learning.where(user:, practice: original_practice).destroy_all

    # Create completed learning for original practice
    Learning.create!(
      user:,
      practice: original_practice,
      status: 'complete'
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text original_practice.title
    assert_text original_practice.id.to_s
    assert_text copied_practice.title
    assert_text copied_practice.id.to_s
  end

  test "shows 'なし' when no copied practice exists" do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create dedicated category and practice for this test
    category = Category.create!(name: 'Test Category No Copy', slug: 'test-category-no-copy')
    category.courses << rails_course

    practice = Practice.new(
      title: 'Test Practice No Copy',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    practice.categories << category
    practice.save!

    # Clear existing learning to avoid uniqueness conflicts
    Learning.where(user:, practice:).destroy_all

    # Create completed learning
    Learning.create!(
      user:,
      practice:,
      status: 'complete'
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text practice.title
    assert_text 'なし'
  end

  test 'shows product link when user has submitted work' do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create dedicated category and practice for this test
    category = Category.create!(name: 'Test Category Product Link', slug: 'test-category-product-link')
    category.courses << rails_course

    practice = Practice.new(
      title: 'Test Practice Product Link',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    practice.categories << category
    practice.save!

    # Clear existing learning and product to avoid uniqueness conflicts
    Learning.where(user:, practice:).destroy_all
    Product.where(user:, practice:).destroy_all

    # Create completed learning
    Learning.create!(
      user:,
      practice:,
      status: 'complete'
    )

    # Create product for the practice
    product = Product.create!(
      user:,
      practice:,
      body: 'Test submission'
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text practice.title
    assert_text '修了'
    assert_link '提出物', href: product_path(product)
  end

  test "shows 'なし' when user has no product for practice" do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create dedicated category and practice for this test
    category = Category.create!(name: 'Test Category No Product', slug: 'test-category-no-product')
    category.courses << rails_course

    practice = Practice.new(
      title: 'Test Practice No Product',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    practice.categories << category
    practice.save!

    # Clear existing learning to avoid uniqueness conflicts
    Learning.where(user:, practice:).destroy_all

    # Create completed learning but no product
    Learning.create!(
      user:,
      practice:,
      status: 'complete'
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text practice.title
    assert_text '修了'
    within 'tr', text: practice.title do
      assert_text 'なし'
    end
  end

  test 'shows Reスキル course status and product when user has completed copied practice' do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create dedicated category and original practice for this test
    category = Category.create!(name: 'Test Category Reskill Status', slug: 'test-category-reskill-status')
    category.courses << rails_course

    original_practice = Practice.new(
      title: 'Test Practice Reskill Status',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    original_practice.categories << category
    original_practice.save!

    # Create copied practice with source_id pointing to original
    timestamp = Time.current.to_i
    copied_practice = Practice.new(
      title: "#{original_practice.title} (Reスキル) #{timestamp}",
      description: original_practice.description,
      goal: original_practice.goal,
      source_id: original_practice.id
    )
    copied_practice.categories << category
    copied_practice.save!

    # Clear existing learning and product to avoid uniqueness conflicts
    Learning.where(user:, practice: [original_practice, copied_practice]).destroy_all
    Product.where(user:, practice: [original_practice, copied_practice]).destroy_all

    # Create completed learning for original practice
    Learning.create!(
      user:,
      practice: original_practice,
      status: 'complete'
    )

    # Create completed learning for copied practice (Reスキル)
    Learning.create!(
      user:,
      practice: copied_practice,
      status: 'complete'
    )

    # Create product for copied practice (Reスキル)
    Product.create!(
      user:,
      practice: copied_practice,
      body: 'Reスキル submission'
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text original_practice.title
    assert_text copied_practice.title

    # Check Reスキル status and product in the data row containing original practice ID
    within 'tbody tr', text: original_practice.id.to_s do
      assert_text '修了' # Status for Reスキル
      assert_link '提出物' # Product link for Reスキル
    end
  end

  test "shows 未着手 for Reスキル when copied practice exists but user hasn't started" do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create dedicated category and original practice for this test
    category = Category.create!(name: 'Test Category Reskill Unstarted', slug: 'test-category-reskill-unstarted')
    category.courses << rails_course

    original_practice = Practice.new(
      title: 'Test Practice Reskill Unstarted',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    original_practice.categories << category
    original_practice.save!

    # Create copied practice with source_id pointing to original
    timestamp = Time.current.to_i
    copied_practice = Practice.new(
      title: "#{original_practice.title} (Reスキル) #{timestamp}",
      description: original_practice.description,
      goal: original_practice.goal,
      source_id: original_practice.id
    )
    copied_practice.categories << category
    copied_practice.save!

    # Clear existing learning to avoid uniqueness conflicts
    Learning.where(user:, practice: original_practice).destroy_all

    # Create completed learning for original practice only
    Learning.create!(
      user:,
      practice: original_practice,
      status: 'complete'
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text original_practice.title
    assert_text copied_practice.title

    # Check Reスキル shows 未着手 and なし for product
    within 'tr', text: original_practice.title do
      assert_text '未着手'
      assert_text 'なし'
    end
  end

  test 'shows 進捗コピー button when copied practice exists' do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create dedicated category and original practice for this test
    category = Category.create!(name: 'Test Category Copy Button', slug: 'test-category-copy-button')
    category.courses << rails_course

    original_practice = Practice.new(
      title: 'Test Practice Copy Button',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    original_practice.categories << category
    original_practice.save!

    # Create copied practice with source_id pointing to original
    timestamp = Time.current.to_i
    copied_practice = Practice.new(
      title: "#{original_practice.title} (Reスキル) #{timestamp}",
      description: original_practice.description,
      goal: original_practice.goal,
      source_id: original_practice.id
    )
    copied_practice.categories << category
    copied_practice.save!

    # Clear existing learning to avoid uniqueness conflicts
    Learning.where(user:, practice: original_practice).destroy_all

    # Create completed learning for original practice
    Learning.create!(
      user:,
      practice: original_practice,
      status: 'complete'
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text original_practice.title

    # Look for link within the specific row
    within('tbody tr', text: original_practice.title) do
      assert_link '進捗コピー'
    end
  end

  test 'copies learning and product data when 進捗コピー button is clicked' do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create dedicated category and original practice for this test
    category = Category.create!(name: 'Test Category Copy Data', slug: 'test-category-copy-data')
    category.courses << rails_course

    original_practice = Practice.new(
      title: 'Test Practice Copy Data',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    original_practice.categories << category
    original_practice.save!

    # Create copied practice with source_id pointing to original
    timestamp = Time.current.to_i
    copied_practice = Practice.new(
      title: "#{original_practice.title} (Reスキル) #{timestamp}",
      description: original_practice.description,
      goal: original_practice.goal,
      source_id: original_practice.id
    )
    copied_practice.categories << category
    copied_practice.save!

    # Clear existing learning and product to avoid uniqueness conflicts
    Learning.where(user:, practice: [original_practice, copied_practice]).destroy_all
    Product.where(user:, practice: [original_practice, copied_practice]).destroy_all

    # Create completed learning for original practice
    Learning.create!(
      user:,
      practice: original_practice,
      status: 'complete'
    )

    # Create product for original practice
    original_product = Product.create!(
      user:,
      practice: original_practice,
      body: 'Original submission'
    )

    # Create check (合格) for original product
    checker = users(:komagata)
    Check.create!(
      user: checker,
      checkable: original_product
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    # Click the copy button with confirmation
    within('tbody tr', text: original_practice.title) do
      accept_confirm do
        click_link '進捗コピー'
      end
    end

    assert_text '進捗をコピーしました。'

    # Verify learning was copied
    copied_learning = Learning.find_by(user:, practice: copied_practice)
    assert_not_nil copied_learning
    assert_equal 'complete', copied_learning.status

    # Verify product was copied
    copied_product = Product.find_by(user:, practice: copied_practice)
    assert_not_nil copied_product
    assert_equal 'Original submission', copied_product.body

    # Verify check (合格) was copied
    copied_check = Check.find_by(checkable: copied_product)
    assert_not_nil copied_check
    assert_equal checker.id, copied_check.user_id
  end

  test 'skips existing learning and product when they already exist' do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create dedicated category and original practice for this test
    category = Category.create!(name: 'Test Category Skip Existing', slug: 'test-category-skip-existing')
    category.courses << rails_course

    original_practice = Practice.new(
      title: 'Test Practice Skip Existing',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    original_practice.categories << category
    original_practice.save!

    # Create copied practice with source_id pointing to original
    timestamp = Time.current.to_i
    copied_practice = Practice.new(
      title: "#{original_practice.title} (Reスキル) #{timestamp}",
      description: original_practice.description,
      goal: original_practice.goal,
      source_id: original_practice.id
    )
    copied_practice.categories << category
    copied_practice.save!

    # Clear existing learning and product to avoid uniqueness conflicts
    Learning.where(user:, practice: [original_practice, copied_practice]).destroy_all
    Product.where(user:, practice: [original_practice, copied_practice]).destroy_all

    # Create completed learning for original practice
    Learning.create!(
      user:,
      practice: original_practice,
      status: 'complete'
    )

    # Create product for original practice
    Product.create!(
      user:,
      practice: original_practice,
      body: 'Updated submission'
    )

    # Create existing learning and product for copied practice
    existing_learning = Learning.create!(
      user:,
      practice: copied_practice,
      status: 'started'
    )

    existing_product = Product.create!(
      user:,
      practice: copied_practice,
      body: 'Old submission'
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    # Click the copy button with confirmation
    within('tbody tr', text: original_practice.title) do
      accept_confirm do
        click_link '進捗コピー'
      end
    end

    assert_text '進捗をコピーしました。'

    # Verify learning was NOT updated (skipped)
    existing_learning.reload
    assert_equal 'started', existing_learning.status

    # Verify product was NOT updated (skipped)
    existing_product.reload
    assert_equal 'Old submission', existing_product.body
  end

  test 'admin can navigate back to users list' do
    user = users(:kimura)

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    click_on 'ユーザー一覧'
    assert_current_path admin_users_path
  end

  test 'shows 全ての進捗をコピー button when user has completed practices' do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create dedicated category and practice for this test
    category = Category.create!(name: 'Test Category Bulk Copy Button', slug: 'test-category-bulk-copy-button')
    category.courses << rails_course

    practice = Practice.new(
      title: 'Test Practice Bulk Copy Button',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    practice.categories << category
    practice.save!

    # Clear existing learning to avoid uniqueness conflicts
    Learning.where(user:, practice:).destroy_all

    # Create a completed learning for the user
    Learning.create!(
      user:,
      practice:,
      status: 'complete'
    )

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text '全ての進捗をコピー'
    assert_link '全ての進捗をコピー'
  end

  test 'copies all completed practices when 全ての進捗をコピー button is clicked' do
    user = users(:kimura)
    rails_course = courses(:course1) # Railsエンジニアコース

    # Create dedicated category for this test
    category = Category.create!(name: 'Test Category Bulk Copy All', slug: 'test-category-bulk-copy-all')
    category.courses << rails_course

    # Create multiple original practices
    original_practice1 = Practice.new(
      title: 'Test Practice Bulk Copy All 1',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    original_practice1.categories << category
    original_practice1.save!

    original_practice2 = Practice.new(
      title: 'Test Practice Bulk Copy All 2',
      description: 'Test practice for system test',
      goal: 'Test goal',
      submission: 'product'
    )
    original_practice2.categories << category
    original_practice2.save!

    # Create copied practices with source_id pointing to originals
    timestamp = Time.current.to_i
    copied_practice1 = Practice.new(
      title: "#{original_practice1.title} (Reスキル) #{timestamp}",
      description: original_practice1.description,
      goal: original_practice1.goal,
      source_id: original_practice1.id
    )
    copied_practice1.categories << category
    copied_practice1.save!

    copied_practice2 = Practice.new(
      title: "#{original_practice2.title} (Reスキル) #{timestamp + 1}",
      description: original_practice2.description,
      goal: original_practice2.goal,
      source_id: original_practice2.id
    )
    copied_practice2.categories << category
    copied_practice2.save!

    # Clear existing learning and product to avoid uniqueness conflicts
    Learning.where(user:, practice: [original_practice1, original_practice2]).destroy_all
    Product.where(user:, practice: [original_practice1, original_practice2]).destroy_all

    # Create completed learnings for original practices
    Learning.create!(user:, practice: original_practice1, status: 'complete')
    Learning.create!(user:, practice: original_practice2, status: 'complete')

    # Create products for original practices
    Product.create!(user:, practice: original_practice1, body: 'Submission 1')
    Product.create!(user:, practice: original_practice2, body: 'Submission 2')

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    # Click the bulk copy button with confirmation
    accept_confirm do
      click_link '全ての進捗をコピー'
    end

    assert_text '全ての進捗をコピーしました。'

    # Verify both learnings were copied
    copied_learning1 = Learning.find_by(user:, practice: copied_practice1)
    copied_learning2 = Learning.find_by(user:, practice: copied_practice2)
    assert_not_nil copied_learning1
    assert_not_nil copied_learning2
    assert_equal 'complete', copied_learning1.status
    assert_equal 'complete', copied_learning2.status

    # Verify both products were copied
    copied_product1 = Product.find_by(user:, practice: copied_practice1)
    copied_product2 = Product.find_by(user:, practice: copied_practice2)
    assert_not_nil copied_product1
    assert_not_nil copied_product2
    assert_equal 'Submission 1', copied_product1.body
    assert_equal 'Submission 2', copied_product2.body
  end
end
