class CreateGoodJobExecutions < ActiveRecord::Migration[7.2]
  def change
    create_table :good_job_executions, id: :uuid do |t|
      t.timestamps

      t.uuid :active_job_id, null: false
      t.text :job_class
      t.text :queue_name
      t.jsonb :serialized_params
      t.datetime :scheduled_at
      t.datetime :finished_at
      t.text :error
      t.integer :error_event, limit: 2
      t.text :error_backtrace, array: true
      t.uuid :process_id
      t.interval :duration
    end

    add_index :good_job_executions, [:active_job_id, :created_at], name: :index_good_job_executions_on_active_job_id_and_created_at
    add_index :good_job_executions, [:process_id, :created_at], name: :index_good_job_executions_on_process_id_and_created_at
  end
end
