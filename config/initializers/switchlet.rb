# frozen_string_literal: true

Switchlet.configure do |config|
  config.authenticate_with do |controller|
    User.find_by(id: controller.session[:user_id])&.admin?
  end
end

# development環境でsmart_searchをデフォルトで有効化
Rails.application.config.after_initialize do
  if Rails.env.development? && ActiveRecord::Base.connection.table_exists?('switchlet_features')
    Switchlet.enable!(:smart_search) unless Switchlet.enabled?(:smart_search)
  end
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
  # DB未作成時やマイグレーション前は無視
end
