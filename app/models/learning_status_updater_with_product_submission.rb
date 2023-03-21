# frozen_string_literal: true

class LearningStatusUpdaterWithProductSubmission
  def call(product)
    previous_learning = Learning.find_or_initialize_by(
      user_id: product.user.id,
      practice_id: product.practice.id
    )
    status = if previous_learning.status == 'complete'
               :complete
             elsif product.wip
               started_practice = product.user.learnings.map(&:status).include?('started')
               started_practice ? :unstarted : :started
             else
               :submitted
             end
    product.change_learning_status status
  end
end
