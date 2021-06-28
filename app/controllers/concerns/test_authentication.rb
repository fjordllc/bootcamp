# frozen_string_literal: true

module TestAuthentication
  extend ActiveSupport::Concern

  def test_login
    login(params[:_login_name], 'testtest') if params[:_login_name]
  end
end
