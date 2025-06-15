# frozen_string_literal: true

class CopyPracticeProgress
  include Interactor

  def call
    ActiveRecord::Base.transaction do
      run_learning_copy
      run_product_copy
      run_check_copy
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    context.fail!(error: e.message)
  end

  private

  def run_learning_copy
    result = CopyLearning.call(context.to_h)
    merge_result(result)
  end

  def run_product_copy
    result = CopyProduct.call(context.to_h)
    merge_result(result)
  end

  def run_check_copy
    result = CopyCheck.call(context.to_h)
    merge_result(result)
  end

  def merge_result(result)
    if result.success?
      # Merge successful result data into context
      result.to_h.each { |key, value| context[key] = value }
    else
      context.fail!(error: result.error)
    end
  end
end
