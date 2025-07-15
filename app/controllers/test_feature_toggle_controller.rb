class TestFeatureToggleController < ApplicationController
  before_action -> { authorize_feature(:test_feature_toggle, [User.find_by(login_name: 'kimura'), User.admins]) }
  before_action -> { authorized_feature!(:test_feature_toggle) }
  def index
    @user = User.first
  end
end
