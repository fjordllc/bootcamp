class User < ActiveRecord::Base
  authenticates_with_sorcery!
  has_many :learnings

  validates_length_of :password,
    minimum: 4,
    if: :password,
    message: "password must be at least 3 characters long"
  validates_confirmation_of :password,
    if: :password,
    message: "should match confirmation"
  validates :login_name, presence: true
  validates :email, presence: true
  validates :name, presence: true
  validates :name_kana, presence: true
end
