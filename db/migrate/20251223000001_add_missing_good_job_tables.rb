# frozen_string_literal: true

class AddMissingGoodJobTables < ActiveRecord::Migration[7.2]
  def change
    # Create good_job_batches table if it doesn't exist
    unless table_exists?(:good_job_batches)
      create_table :good_job_batches, id: :uuid do |t|
        t.timestamps
        t.text :description
        t.jsonb :serialized_properties
        t.text :on_finish
        t.text :on_success
        t.text :on_discard
        t.text :callback_queue_name
        t.integer :callback_priority
        t.datetime :enqueued_at
        t.datetime :discarded_at
        t.datetime :finished_at
        t.datetime :jobs_finished_at
      end
    end

    # Create good_job_executions table if it doesn't exist
    unless table_exists?(:good_job_executions)
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

    # Create good_job_processes table if it doesn't exist
    unless table_exists?(:good_job_processes)
      create_table :good_job_processes, id: :uuid do |t|
        t.timestamps
        t.jsonb :state
        t.integer :lock_type, limit: 2
      end
    end

    # Create good_job_settings table if it doesn't exist
    unless table_exists?(:good_job_settings)
      create_table :good_job_settings, id: :uuid do |t|
        t.timestamps
        t.text :key
        t.jsonb :value
      end
      add_index :good_job_settings, :key, unique: true
    end
  end
end
