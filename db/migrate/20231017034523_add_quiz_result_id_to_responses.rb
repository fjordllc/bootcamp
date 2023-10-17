class AddQuizResultIdToResponses < ActiveRecord::Migration[6.1]
  def change
    add_reference :responses, :quiz_result, null: false, foreign_key: true
  end
end
