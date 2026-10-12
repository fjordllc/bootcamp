# frozen_string_literal: true

class UserCoursePractice
  attr_reader :user

  delegate :courses, to: :user
  MAX_PERCENTAGE = 100

  def self.counts_by_user(users)
    counts = users.to_h { |user| [user.id, { required: 0, completed: 0, completed_required: 0 }] }
    return counts if counts.empty?

    practices = Practice.joins(categories: { courses: :users }).where(users: { id: counts.keys })
    required = practices.where(include_progress: true)
                        .joins('LEFT JOIN skipped_practices ON skipped_practices.practice_id = practices.id AND skipped_practices.user_id = users.id')
                        .where(skipped_practices: { id: nil })
    completed = practices.joins(:learnings).where('learnings.user_id = users.id').where(learnings: { status: 'complete' })
    completed_required = required.joins(:learnings).where('learnings.user_id = users.id').where(learnings: { status: 'complete' })
    { required:, completed:, completed_required: }.each do |name, scope|
      scope.group('users.id').count('DISTINCT practices.id').each { |user_id, count| counts.fetch(user_id)[name] = count }
    end
    counts
  end

  def initialize(user)
    @user = user
  end

  def uniq_practice_ids
    @user.course.practices.uniq.pluck(:id)
  end

  def categories_for_skip_practice
    filtered_categories = []
    practice_ids = uniq_practice_ids
    @user.course.categories.each do |category|
      copied_category, practice_ids = filter_category_by_practice_ids(category, practice_ids)
      filtered_categories << copied_category
    end
    filtered_categories
  end

  def sorted_practices
    @user.course.practices.order('courses_categories.position', 'categories_practices.position')
  end

  def skipped_practice_ids
    @user.skipped_practices.pluck(:practice_id)
  end

  def category_active_or_unstarted_practice
    if @user.active_practices.present?
      category_having_active_practice
    elsif unstarted_practices.present?
      category_having_unstarted_practice
    end
  end

  def required_practices
    Practice
      .joins(categories: { courses: :users })
      .where(users: { id: user.id }, include_progress: true)
      .where.not(id: skipped_practice_ids).distinct
  end

  def completed_practices
    Practice
      .joins({ categories: { courses: :users } }, :learnings)
      .where(
        users: { id: user.id },
        learnings: {
          user_id: user.id,
          status: 'complete'
        }
      )
      .distinct
  end

  def completed_required_practices
    Practice
      .joins({ categories: { courses: :users } }, :learnings)
      .where(
        users: { id: user.id },
        learnings: {
          user_id: user.id,
          status: 'complete'
        },
        include_progress: true
      )
      .where.not(id: skipped_practice_ids).distinct
  end

  def completed_percentage
    completed_required_practices.size.to_f / required_practices.size * MAX_PERCENTAGE
  end

  def completed_practices_size_by_category
    Practice
      .joins({ categories: :categories_practices }, :learnings)
      .where(
        learnings: {
          user_id: user.id,
          status: 'complete'
        }
      )
      .group('categories_practices.category_id')
      .count('DISTINCT practices.id')
  end

  private

  def unstarted_practices
    @unstarted_practices ||= UserUnstartedPracticesQuery.call(user: @user)
  end

  def category_having_active_practice
    OrderedCategoriesFromPracticesQuery.call(user: @user, practices: @user.active_practices).first
  end

  def category_having_unstarted_practice
    OrderedCategoriesFromPracticesQuery.call(user: @user, practices: unstarted_practices).first
  end

  def filter_category_by_practice_ids(category, practice_ids)
    filtered_practices = []
    category.practices.each do |practice|
      filtered_practices << practice if practice_ids.delete(practice.id)
    end
    # OpenStructを使用してカテゴリのようなオブジェクトを作成
    # category.dupとhas_many throughの<<の組み合わせはメモリリークを引き起こすため
    category_proxy = OpenStruct.new(
      id: category.id,
      name: category.name,
      practices: filtered_practices,
      practice_ids: filtered_practices.map(&:id)
    )
    [category_proxy, practice_ids]
  end
end
