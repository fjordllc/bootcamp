class RemoveIndexCodingTestIdFromCodingTestSubmissions < ActiveRecord::Migration[8.1]
  def change
    remove_index :coding_test_submissions, :coding_test_id, name: "index_coding_test_submissions_on_coding_test_id"
  end
end
