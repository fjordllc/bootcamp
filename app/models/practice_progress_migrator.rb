# frozen_string_literal: true

class PracticeProgressMigrator
  def initialize(user)
    @user = user
  end

  def migrate(practice_id)
    practice = Practice.find(practice_id)
    copied_practice = Practice.find_by(source_id: practice_id)

    return { success: false, error: 'コピー先のプラクティスが見つかりません。' } unless copied_practice

    copy_learning_data(practice, copied_practice)
    copy_product_data(practice, copied_practice)

    { success: true, message: '進捗をコピーしました。' }
  end

  def migrate_all
    presenter = PracticeProgressPresenter.new(@user)
    completed_practices = presenter.completed_practices

    process_all_practices(completed_practices)

    { success: true, message: '全ての進捗をコピーしました。' }
  end

  private

  def process_all_practices(completed_practices)
    completed_practices.each do |learning|
      practice = learning.practice
      copied_practice = Practice.find_by(source_id: practice.id)

      next unless copied_practice

      copy_learning_data(practice, copied_practice)
      copy_product_data(practice, copied_practice)
    end
  end

  def copy_learning_data(practice, copied_practice)
    original_learning = Learning.find_by(user: @user, practice:)
    return unless original_learning

    existing_learning = Learning.find_by(user: @user, practice: copied_practice)
    if existing_learning
      existing_learning.update!(status: original_learning.status)
    else
      Learning.create!(
        user: @user,
        practice: copied_practice,
        status: original_learning.status
      )
    end
  end

  def copy_product_data(practice, copied_practice)
    original_product = Product.find_by(user: @user, practice:)
    return unless original_product

    copied_product = copy_product(original_product, copied_practice)
    copy_check_data(original_product, copied_product)
  end

  def copy_product(original_product, copied_practice)
    existing_product = Product.find_by(user: @user, practice: copied_practice)
    if existing_product
      existing_product.update!(
        body: original_product.body,
        wip: original_product.wip
      )
      existing_product
    else
      Product.create!(
        user: @user,
        practice: copied_practice,
        body: original_product.body,
        wip: original_product.wip
      )
    end
  end

  def copy_check_data(original_product, copied_product)
    original_check = Check.find_by(checkable: original_product)
    return unless original_check

    existing_check = Check.find_by(checkable: copied_product)
    return if existing_check

    Check.create!(
      user: original_check.user,
      checkable: copied_product
    )
  end
end
