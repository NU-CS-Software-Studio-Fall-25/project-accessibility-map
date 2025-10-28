class FixSolidQueueTables < ActiveRecord::Migration[8.0]
  # We disable the transaction because adding foreign keys can fail inside transactions
  disable_ddl_transaction!

  def change
    # Add missing columns only if they don't exist
    change_table :solid_queue_jobs, bulk: true do |t|
      t.string   :class_name        unless column_exists?(:solid_queue_jobs, :class_name)
      t.text     :arguments         unless column_exists?(:solid_queue_jobs, :arguments)
      t.datetime :scheduled_at      unless column_exists?(:solid_queue_jobs, :scheduled_at)
      t.datetime :finished_at       unless column_exists?(:solid_queue_jobs, :finished_at)
      t.string   :concurrency_key   unless column_exists?(:solid_queue_jobs, :concurrency_key)
      t.integer  :priority          unless column_exists?(:solid_queue_jobs, :priority)
    end

    # Add missing indexes
    add_index :solid_queue_jobs, :class_name unless index_exists?(:solid_queue_jobs, :class_name)
    add_index :solid_queue_jobs, :finished_at unless index_exists?(:solid_queue_jobs, :finished_at)
    add_index :solid_queue_jobs, [:queue_name, :finished_at],
              name: "index_solid_queue_jobs_for_filtering" unless index_exists?(:solid_queue_jobs, [:queue_name, :finished_at], name: "index_solid_queue_jobs_for_filtering")
    add_index :solid_queue_jobs, [:scheduled_at, :finished_at],
              name: "index_solid_queue_jobs_for_alerting" unless index_exists?(:solid_queue_jobs, [:scheduled_at, :finished_at], name: "index_solid_queue_jobs_for_alerting")

    # Add foreign keys only if the tables exist
    add_foreign_key_if_table_exists :solid_queue_blocked_executions, :solid_queue_jobs
    add_foreign_key_if_table_exists :solid_queue_claimed_executions, :solid_queue_jobs
    add_foreign_key_if_table_exists :solid_queue_failed_executions, :solid_queue_jobs
    add_foreign_key_if_table_exists :solid_queue_ready_executions, :solid_queue_jobs
    add_foreign_key_if_table_exists :solid_queue_recurring_executions, :solid_queue_jobs
    add_foreign_key_if_table_exists :solid_queue_scheduled_executions, :solid_queue_jobs
  end

  private

  # Helper to add a foreign key only if the referenced table exists
  def add_foreign_key_if_table_exists(from_table, to_table)
    if table_exists?(from_table) && !foreign_key_exists?(from_table, to_table)
      add_foreign_key from_table, to_table, column: "job_id", on_delete: :cascade
    end
  end
end
