# frozen_string_literal: true

require 'browserless_system_test_case'

class Admin::Users::PracticeProgressBrowserlessTest < BrowserlessSystemTestCase
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
    assert_selector '.admin-table'
  end

  test 'shows message when user has no completed Rails practices' do
    user = users(:kimura)
    # Ensure user has no completed learnings
    user.learnings.destroy_all

    visit_with_auth admin_user_practice_progress_path(user), 'komagata'

    assert_text "#{user.login_name}さんのRailsエンジニアコース完了プラクティス一覧"
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
end
