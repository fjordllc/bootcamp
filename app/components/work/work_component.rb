# frozen_string_literal: true

class Work::WorkComponent < ViewComponent::Base
  def initialize(work:)
    @work = work
  end

  private

  attr_reader :work
end
