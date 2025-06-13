# frozen_string_literal: true

class PracticeProgressPresenter
  include ActionView::Helpers

  attr_reader :user, :course

  def initialize(user, course: Course.rails_course)
    @user = user
    @course = course
  end

  def completed_practices
    @completed_practices ||= CompletedLearningsQuery
                             .new(user.learnings, course:)
                             .call
                             .includes(
                               :practice,
                               practice: {
                                 copied_practices: [
                                   { learnings: :user },
                                   { products: %i[user checks] }
                                 ]
                               }
                             )
  end

  def copied_practices_for(practice_ids)
    Practice.where(source_id: practice_ids)
            .includes(%i[learnings products], learnings: :user, products: %i[user checks])
            .where(learnings: { user: })
  end

  def user_products_for(practice_ids)
    user.products.where(practice_id: practice_ids)
        .includes(:practice, :checks)
  end

  def migration_candidates
    completed_practice_ids = completed_practices.pluck(:practice_id)
    completed_practices.joins(:practice)
                       .where(practices: { source_id: nil })
                       .where.not(practice_id: Practice.where(source_id: completed_practice_ids).pluck(:source_id))
  end

  def copied_practice_learnings_for(copied_practice_ids)
    user.learnings.where(practice_id: copied_practice_ids)
        .includes(:practice)
  end

  def copied_practice_products_for(copied_practice_ids)
    user.products.where(practice_id: copied_practice_ids)
        .includes(:practice, :checks)
  end

  # Presenter helper methods
  delegate :count, to: :completed_practices, prefix: true

  def migration_progress_percentage
    return 0 if completed_practices_count.zero?

    migrated_count = copied_practices_for(completed_practices.pluck(:practice_id)).count
    (migrated_count.to_f / completed_practices_count * 100).round(2)
  end

  def migration_candidates?
    migration_candidates.exists?
  end

  def practice_status_for(practice)
    if practice.source_id.present?
      'copied'
    elsif copied_practices_for([practice.id]).exists?
      'has_copy'
    else
      'original'
    end
  end

  # View helper methods
  def product_for(learning)
    @products_cache ||= user.products.where(practice_id: completed_practices.pluck(:practice_id))
                            .includes(:practice, :checks)
                            .index_by(&:practice_id)
    @products_cache[learning.practice_id]
  end

  def copied_practice_for(practice)
    @copied_practices_cache ||= {}
    @copied_practices_cache[practice.id] ||= practice.copied_practices
                                                     .joins(:learnings)
                                                     .where(learnings: { user: })
                                                     .includes(learnings: [], products: %i[checks])
                                                     .first
  end

  def copied_learning_for(copied_practice)
    return nil unless copied_practice

    copied_practice.learnings.find { |l| l.user == user }
  end

  def copied_product_for(copied_practice)
    return nil unless copied_practice

    copied_practice.products.find { |p| p.user == user }
  end

  def has_copy_destination?(practice)
    copy_destinations.include?(practice.id)
  end

  def copy_destination_practice_for(practice)
    copy_destination_practices[practice.id]
  end

  private

  def copy_destinations
    @copy_destinations ||= Practice.where(source_id: completed_practices.pluck(:practice_id))
                                   .pluck(:source_id)
                                   .to_set
  end

  def copy_destination_practices
    @copy_destination_practices ||= Practice.where(source_id: completed_practices.pluck(:practice_id))
                                            .includes(:learnings, :products, learnings: :user, products: [:user, :checks])
                                            .index_by(&:source_id)
  end
end
