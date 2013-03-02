class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :authentications_attributes, :icon_url
  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications
end
