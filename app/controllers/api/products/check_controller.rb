# frozen_string_literal: true

class API::Products::CheckController < API::CheckableChecksController
  private

  def checkable_class
    Product
  end
end
