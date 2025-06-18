# frozen_string_literal: true

module FeatureToggle
  extend ActiveSupport::Concern

  included do
    helper_method :authorized_feature?
  end

  def authorized_feature?(feature_key)
    Flipper[feature_key].enabled?(current_user)
  end

  def authorized_feature!(feature_key)
    raise ActionController::RoutingError, 'Feature disabled' unless authorized_feature?(feature_key)
  end

  def authorize_feature(feature_key, actors)
    Array(actors).flatten.each do |actor|
      Flipper.enable_actor(feature_key, actor)
    end
  end
end
