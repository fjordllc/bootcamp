# frozen_string_literal: true

class LearningStatusUpdater
  def call(payload)
    product_or_associated_object = payload[:product] || payload[:check]
    case product_or_associated_object
    when Product
      update_after_submission(product_or_associated_object)
    when Check
      if Check.exists?(product_or_associated_object.id)
        update_after_check(product_or_associated_object)
      else
        update_after_cancel_check(product_or_associated_object)
      end
    end
  end

  def update_after_check(check)
    return unless check.checkable_type == 'Product'

    check.checkable.change_learning_status(:complete)
  end

  def update_after_cancel_check(check)
    return unless check.checkable_type == 'Product'

    check.checkable.change_learning_status(:submitted)
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
    product.change_learning_status status
  end
end
