# frozen_string_literal: true

class LearningStatusUpdater
  def call(_name, _started, _finished, _id, payload)
    product_or_associated_object = payload[:product] || payload[:check]
    case product_or_associated_object
    when Product
      update_after_submission(product_or_associated_object)
    when Check
      update_after_check(product_or_associated_object)
    end
  end

  def update_after_check(check)
    return unless check.checkable_type == 'Product'

    learning_status = if check.checkable.checked? && check.checkable.practice.quiz_gate.completable_by?(check.checkable.user)
                        :complete
                      else
                        :submitted
                      end
    change_learning_status(check.checkable, learning_status)
  end

  def update_after_submission(product)
    previous_learning = Learning.find_or_initialize_by(
      user_id: product.user.id,
      practice_id: product.practice.id
    )
    status = if previous_learning.status == 'complete'
               :complete
             elsif product.wip
               started_practice = product.user.learnings.map(&:status).include?('started')
               started_practice && previous_learning.status != 'started' ? :unstarted : :started
             else
               :submitted
             end
    change_learning_status(product, status)
  end

  def change_learning_status(product, status)
    learning = Learning.find_or_initialize_by(
      user_id: product.user.id,
      practice_id: product.practice.id
    )
    learning.update!(status:)
  end
end
