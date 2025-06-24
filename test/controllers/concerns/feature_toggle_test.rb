# frozen_string_literal: true

require 'test_helper'

class FeatureToggleTest < ActionDispatch::IntegrationTest
  fixtures :users

  class ExampleController < ApplicationController
    include FeatureToggle

    attr_accessor :current_user
  end

  setup do
    @user = users(:kimura)
    @controller = ExampleController.new
    @controller.current_user = @user
  end

  test 'authorized_feature?' do
    # All features are disabled by default
    assert_not @controller.authorized_feature?(:some_feature)

    Flipper.enable(:some_feature, @user)
    assert @controller.authorized_feature?(:some_feature)
  end

  test 'authorized_feature!' do
    # All features are disabled by default
    error = assert_raises(ActionController::RoutingError) do
      @controller.authorized_feature!(:some_feature)
    end
    assert_equal 'Feature disabled', error.message

    Flipper.enable(:some_feature, @user)
    assert_nil @controller.authorized_feature!(:some_feature)
  end

  test 'authorize_feature' do
    @controller.authorize_feature(:some_feature, [users(:kensyu), User.admins, User.mentor])

    assert_not Flipper[:some_feature].enabled?(@controller.current_user)
    assert Flipper[:some_feature].enabled?(users(:kensyu))
    assert Flipper[:some_feature].enabled?(User.admins.to_a.sample)
    assert Flipper[:some_feature].enabled?(User.mentor.to_a.sample)
  end
end
