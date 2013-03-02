class Authentication < ActiveRecord::Base
  attr_accessible :user_id, :provider, :uid, :created_at, :updated_at
  belongs_to :user
end
