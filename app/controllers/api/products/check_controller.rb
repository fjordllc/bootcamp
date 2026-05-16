# frozen_string_literal: true

class API::Products::CheckController < API::BaseController
  include API::CheckableCheck

  private

  def checkable_class
    Product
  end
end
