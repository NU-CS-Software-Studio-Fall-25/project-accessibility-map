class CreateSolidQueueBlockedExecutions < ActiveRecord::Migration[7.1]
  def change
    create_table :solid_queue_blocked_executions do |t|
      t.bigint :job_id, null: false
      t.string :queue_name, null: false
      t.integer :priority, null: false, default: 0
      t.string :concurrency_key, null: false
      t.datetime :expires_at, null: false
      t.timestamps null: false

      t.index [:concurrency_key, :priority, :job_id], name: "index_solid_queue_blocked_executions_for_release"
      t.index [:expires_at, :concurrency_key], name: "index_solid_queue_blocked_executions_for_maintenance"
      t.index :job_id, unique: true
    end

    add_foreign_key :solid_queue_blocked_executions, :solid_queue_jobs, column: :job_id, on_delete: :cascade
  end
end
