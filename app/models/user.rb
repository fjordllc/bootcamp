class User < ActiveRecord::Base
  authenticates_with_sorcery!
  has_many :learnings
  validates_length_of :password, minimum: 4, if: :password
  validates_confirmation_of :password, if: :password
  validates :login_name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
end
