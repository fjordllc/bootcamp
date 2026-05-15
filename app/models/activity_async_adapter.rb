# frozen_string_literal: true

class ActivityAsyncAdapter
  def initialize(params = {})
    @params = params
  end

  def enqueue(_, params = {})
    params.merge!(@params)
    ActivityJob.perform_later(params)
  end
end
