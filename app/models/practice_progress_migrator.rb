# frozen_string_literal: true

class PracticeProgressMigrator
  def initialize(user)
    @user = user
  end

  def migrate(practice_id)
    practice = Practice.find(practice_id)
    copied_practice = Practice.find_by(source_id: practice_id)

    return false unless copied_practice

    result = CopyPracticeProgress.call(
      user: @user,
      from_practice: practice,
      to_practice: copied_practice
    )

    result.success?
  end

  def migrate_all
    presenter = PracticeProgressPresenter.new(@user)
    completed_practices = presenter.completed_practices

    context = Interactor::Context.new

    ActiveRecord::Base.transaction do
      unless process_all_practices(completed_practices)
        context.fail!(error: 'Failed to migrate all practice progress')
        raise ActiveRecord::Rollback
      end
    end

    context
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    Rails.logger.error "PracticeProgressMigrator#migrate_all failed: #{e.message}"
    context.fail!(error: e.message)
  end

  private

  def process_all_practices(completed_practices)
    completed_practices.each do |learning|
      practice = learning.practice
      copied_practice = Practice.find_by(source_id: practice.id)

      next unless copied_practice

      result = CopyPracticeProgress.call(
        user: @user,
        from_practice: practice,
        to_practice: copied_practice
      )

      unless result.success?
        Rails.logger.error "Failed to copy practice progress for practice #{practice.id}: #{result.error}"
        return false
      end
    end

    true
  end
end
