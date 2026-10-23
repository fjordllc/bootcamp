# frozen_string_literal: true

class Admin::PerformanceController < AdminController
  def index
    @performance = Performance::Snapshot.fetch
    response.headers['Cache-Control'] = 'no-store'
  end
end
