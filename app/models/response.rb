class Response < ApplicationRecord
  belongs_to :quiz_result
  belongs_to :statement
end
