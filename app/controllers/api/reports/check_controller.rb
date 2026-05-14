# frozen_string_literal: true

class API::Reports::CheckController < API::BaseController
  include API::CheckableCheck

  private

  def checkable_class
    Report
  end
end
