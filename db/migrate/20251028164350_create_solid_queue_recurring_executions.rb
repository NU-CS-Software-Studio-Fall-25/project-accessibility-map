class CreateSolidQueueRecurringExecutions < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_queue_recurring_executions do |t|
      t.bigint :job_id, null: false
      t.string :task_key, null: false
      t.datetime :run_at, null: false
      t.datetime :created_at, null: false

      t.index :job_id, unique: true
      t.index [:task_key, :run_at], unique: true
    end

    add_foreign_key :solid_queue_recurring_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
  end
end
