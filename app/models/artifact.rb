class Artifact < ApplicationRecord
  belongs_to :user
  belongs_to :practice
end
