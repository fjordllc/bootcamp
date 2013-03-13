class User < ActiveRecord::Base
  authenticates_with_sorcery!

  validates_length_of :password,
    minimum: 4,
    if: :password,
    message: "password must be at least 3 characters long"
  validates_confirmation_of :password,
    if: :password,
    message: "should match confirmation"
end
