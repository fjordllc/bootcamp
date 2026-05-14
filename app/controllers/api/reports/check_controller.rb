# frozen_string_literal: true

class API::Reports::CheckController < API::CheckableChecksController
  private

  def checkable_class
    Report
  end
end
